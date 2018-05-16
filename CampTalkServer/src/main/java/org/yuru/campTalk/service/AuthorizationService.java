package org.yuru.campTalk.service;


import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.GlobalConfigContext;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.entity.YuruAuthEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.*;

import java.sql.Timestamp;
import java.util.UUID;

/**
 * Author: Rinkako&Likthiis
 * Date  : 2018/4/21
 * Usage : Authorize registered users to connect with server.
 */
public class AuthorizationService {
    public static ReturnModel Auth1(String uid, String rawPassword) {
        ReturnModel model = new ReturnModel();
        Session DBsession = HibernateUtil.GetLocalSession();
        try {
            int judge = VerificationByPassword(uid, rawPassword, DBsession);
            model.specialDeal();
            switch(judge) {
                case 1:{
                    model.setCode("user_not_valid");
                    return model;
                }
                case 2:{
                    model.setCode("blocked_account");
                    return model;
                }
                case 3:{
                    model.setCode("password_invalid");
                    return model;
                }
            }
            RuinPassToken(model,uid,DBsession);
            if(model.getCode().equals("cannot_ruin_old_token")) {
                return model;
            }
            SetUserAuthAndSave(model,uid,DBsession);
            if(model.getCode().equals("cannot_insert_info")) {
                return model;
            }
            DBsession.close();
            model.setCode("auth_success");
            return model;
        } catch (Exception ex) {
            String exception = String.format("Request for auth but exception occurred (%s), service rollback, %s", uid, ex);
            LogUtil.Log(exception, AuthorizationService.class.getName(), LogLevelType.ERROR, "");
            model.specialDeal();
            return model;
        }
        finally {
            HibernateUtil.CloseLocalSession();
        }
    }

    public static int VerificationByPassword(String uid, String rawPassword,Session DBsession) {
        String encryptedPassword = EncryptUtil.EncryptSHA256(rawPassword);
        YuruUserEntity user = DBsession.get(YuruUserEntity.class, uid);
        if (user == null) {
            return 1;
        }
        if (user.getStatus() != 0) {
            return 2;
        }
        else if (!user.getPassword().equals(encryptedPassword)) {
            return 3;
        }
        return 0;
    }

    public static void SetUserAuthAndSave(ReturnModel model, String uid, Session DBsession) {
        try {
            Transaction transaction = DBsession.beginTransaction();
            long currentTime = System.currentTimeMillis();
            Timestamp nowTimestamp = new Timestamp(currentTime);
            String tokenId = String.format("AUTH_%s_%s", uid, UUID.randomUUID());
            YuruAuthEntity auth = new YuruAuthEntity();
            auth.setToken(tokenId);
            auth.setUid(uid);
            Timestamp destroyTimeStamp = new Timestamp(currentTime + 1000 * GlobalConfigContext.AUTHORITY_TOKEN_VALID_SECOND);
            auth.setDestroyTimestamp(destroyTimeStamp);
            DBsession.save(auth);
            transaction.commit();
            model.setTimestamp(nowTimestamp.toString());
            model.setToken(tokenId);
        } catch(Exception e) {
            e.printStackTrace();
            DBsession.getTransaction().rollback();
            model.setCode("cannot_insert_info");
        }
    }

    public static void RuinPassToken(ReturnModel model, String uid, Session DBsession) {
        try {
            Transaction transaction = DBsession.beginTransaction();
            while(DBsession.get(YuruAuthEntity.class, uid) != null) {
                YuruAuthEntity auth = DBsession.get(YuruAuthEntity.class, uid);
                    DBsession.delete(auth);
            }
            transaction.commit();
        } catch(Exception e) {
            e.printStackTrace();
            DBsession.getTransaction().rollback();
            model.setCode("cannot_ruin_old_token");
        }
    }

    public static ReturnModel Auth2(String uid, String token) {
        ReturnModel model = new ReturnModel();
        Session DBsession = HibernateUtil.GetLocalSession();
        try{
            model.specialDeal();
            boolean judge = VerificationByToken(DBsession, uid, token, model);
            if(judge){
                RuinPassToken(model,uid,DBsession);
                if(model.getCode().equals("cannot_ruin_old_token")) {
                    return model;
                }
                SetUserAuthAndSave(model,uid,DBsession);
                if(model.getCode().equals("cannot_insert_info")) {
                    return model;
                }
                model.setCode("auth_success");
            }
            return model;
        } catch (Exception ex) {
            String exception = String.format("Request for auth but exception occurred, service rollback, %s", ex);
            LogUtil.Log(exception, AuthorizationService.class.getName(), LogLevelType.ERROR, "");
            model.specialDeal();
            return model;
        }
        finally {
            HibernateUtil.CloseLocalSession();
        }
    }

    public static boolean VerificationByToken(Session DBsession, String uid, String token,ReturnModel model) {
        long currentTime = System.currentTimeMillis();
        Timestamp nowTimestamp = new Timestamp(currentTime);
        YuruAuthEntity auth = DBsession.get(YuruAuthEntity.class, uid);
        if(auth == null) {
            model.setCode("auth_inexist");
            return false;
        }
        if(!auth.getToken().equals(token)) {
            model.setCode("auth_differ");
            return false;
        }
        if(nowTimestamp.after(auth.getDestroyTimestamp())) {
            model.setCode("overdue");
            return false;
        }
        if(auth != null && auth.getToken().equals(token) && nowTimestamp.before(auth.getDestroyTimestamp())) {
            return true;
        }
        model.setCode("other_error");
        return false;
    }
}
