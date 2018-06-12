package org.yuru.campTalk.service;


import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.EncryptUtil;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;
import java.sql.Timestamp;

/**
 * Author: likthiis
 * Date  : 2018/4/22
 * Usage : Handle register.
 */
public class RegisterService {

    public static boolean CheckDuplicateUser(Session DBsession,String uid) {
        YuruUserEntity duplicateUser = DBsession.get(YuruUserEntity.class, uid);
        if(duplicateUser != null) {
            return true;
        }
        else {
            return false;
        }
    }

    public static void InsertUserInfo(Session DBsession,String uid,String encryptedPassword){
        YuruUserEntity user = new YuruUserEntity();
        user.setId(uid);
        // username default equals uid
        user.setUsername(uid);
        user.setPassword(encryptedPassword);
        user.setStatus(0);
        user.setLevel(1);
        user.setCreatetimestamp(new Timestamp(System.currentTimeMillis()));
        user.setLocation("Kamihama");
        // send to database
        DBsession.save(user);
    }

    /**
     * Bring the uid and password to the database.
     */
    public static ReturnModel Register(String uid, String rawPassword) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try{
            String encryptedPassword = EncryptUtil.EncryptSHA256(rawPassword);
            boolean judgeDuplicate = false;
            judgeDuplicate = CheckDuplicateUser(DBsession,uid);
            if(judgeDuplicate) {
                transaction.commit();
                ReturnModel returnModel = new ReturnModel();
                returnModel.successDeal("duplicate_name");
                return returnModel;
            }
            else {
                InsertUserInfo(DBsession,uid,encryptedPassword);
                ImageService.DefaultPicture(uid);
                transaction.commit();
                ReturnModel returnModel = new ReturnModel();
                returnModel.successDeal("register_success");
                return returnModel;
            }
        } catch (Exception ex){
            LogUtil.Log(String.format("Request for login but exception occurred, service rollback, %s", ex),
                    RegisterService.class.getName(), LogLevelType.ERROR, "");
            ReturnModel returnModel = new ReturnModel();
            returnModel.successDeal("exception_occurred");
            transaction.rollback();
            return returnModel;
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }
}
