package org.yuru.campTalk.service;


import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.GlobalConfigContext;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.entity.YuruAuthEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.*;

import java.sql.Timestamp;
import java.util.List;
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
        Transaction transaction = DBsession.beginTransaction();
        try {
            int judge = VerificationByPassword(uid, rawPassword, DBsession);
            switch(judge) {
                case 1:{
                    model.setStatus("user_not_valid");
                    return model;
                }
                case 2:{
                    model.setStatus("blocked_account");
                    return model;
                }
                case 3:{
                    model.setStatus("password_invalid");
                    return model;
                }
            }
            RuinPassToken(model, uid, DBsession);
            if(model.getStatus().equals("cannot_ruin_old_token")) {
                return model;
            }
            SetUserAuthAndSave(model, uid, DBsession);
            if(model.getStatus().equals("cannot_insert_info")) {
                return model;
            }
            transaction.commit();
            model.successDeal("auth_success");
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
//        YuruUserEntity user = DBsession.get(YuruUserEntity.class, uid);

        String query = String.format("from YuruUserEntity as user where user.id = '%s'", uid);
        List<YuruUserEntity> user = DBsession.createQuery(query).list();
        DBsession.clear();
        if(user.size() == 0){
            return 1; //用户不存在
        } else {
            YuruUserEntity yuruUserEntity = user.get(0);
            if (!yuruUserEntity.getId().equals(uid)) { // 比较uid大小写
                return 1;
            } else if (yuruUserEntity.getStatus() != 0) { // 查询状态
                return 2;
            } else if (!yuruUserEntity.getPassword().equals(encryptedPassword)) { // 比较密码
                return 3;
            }
        }
        return 0;
    }

    public static void SetUserAuthAndSave(ReturnModel model, String uid, Session DBsession) {
        try {
            String tokenId = String.format("AUTH_%s_%s", uid, UUID.randomUUID());
            YuruAuthEntity auth = new YuruAuthEntity();
            auth.setToken(tokenId);
            auth.setUid(uid);
            long currentTime = System.currentTimeMillis();
            Timestamp destroyTimeStamp = new Timestamp(currentTime + 1000 * GlobalConfigContext.AUTHORITY_TOKEN_VALID_SECOND);
            auth.setDestroyTimestamp(destroyTimeStamp);
            DBsession.save(auth);
            model.successDeal("success");
            model.setToken(tokenId);
            return;
        } catch(Exception e) {
            e.printStackTrace();
            DBsession.getTransaction().rollback();
            model.setStatus("cannot_insert_info");
        }
    }

    public static void RuinPassToken(ReturnModel model, String uid, Session DBsession) {
        try {
            String query = String.format("from YuruAuthEntity as auth where auth.uid = '%s'", uid);
            List<YuruAuthEntity> list = DBsession.createQuery(query).list();
            if(list.size() > 0) {
                for (YuruAuthEntity o : list) {
                    DBsession.delete(o);
                }
            }
            model.successDeal("success");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            DBsession.getTransaction().rollback();
            model.setStatus("cannot_ruin_old_token");
        }
    }

    public static ReturnModel Auth2(String uid, String token) {
        ReturnModel model = new ReturnModel();
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try{
            boolean judge = VerificationByToken(DBsession, uid, token, model);
            if(judge){
                RuinPassToken(model,uid, DBsession);
                if(model.getStatus().equals("cannot_ruin_old_token")) {
                    return model;
                }
                SetUserAuthAndSave(model,uid,DBsession);
                if(model.getStatus().equals("cannot_insert_info")) {
                    return model;
                }
                model.successDeal("auth_success");
            }
            transaction.commit();
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
            model.setStatus("auth_inexist");
            return false;
        }
        if(!auth.getToken().equals(token)) {
            model.setStatus("auth_differ");
            return false;
        }
        if(nowTimestamp.after(auth.getDestroyTimestamp())) {
            model.setStatus("overdue");
            return false;
        }
        if(auth != null && auth.getToken().equals(token) && nowTimestamp.before(auth.getDestroyTimestamp())) {
            return true;
        }
        return false;
    }
}
