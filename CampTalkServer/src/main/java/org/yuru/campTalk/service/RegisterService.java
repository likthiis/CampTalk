package org.yuru.campTalk.service;


import org.hibernate.Session;
import org.hibernate.Transaction;
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

    public static boolean checkDuplicateUser(Session DBsession,String uid) {
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
    public static String Register(String uid, String rawPassword) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try{
            String encryptedPassword = EncryptUtil.EncryptSHA256(rawPassword);
            boolean judgeDuplicate = false;
            judgeDuplicate = checkDuplicateUser(DBsession,uid);
            if(judgeDuplicate) {
                transaction.commit();
                return "#duplicate_uid";
            }
            if(!judgeDuplicate) {
                InsertUserInfo(DBsession,uid,encryptedPassword);
                ImageSetting.DefaultPicture();
                // transaction finish
                transaction.commit();
            }
            DBsession.close();
            // return the information
            return "#login_success";

        }catch (Exception ex){
            LogUtil.Log(String.format("Request for login but exception occurred, service rollback, %s", ex),
                    AuthorizationService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "#exception_occurred";
        }
    }
}
