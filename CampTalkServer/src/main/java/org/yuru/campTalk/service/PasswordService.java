package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.EncryptUtil;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;

public class PasswordService {
    private static boolean CheckDuplicatePwd(Session DBsession,String username,String password) {
        String encryptedPassword = EncryptUtil.EncryptSHA256(password);
        YuruUserEntity user = DBsession.get(YuruUserEntity.class, username);
        if(!user.getPassword().equals(encryptedPassword)){
            return true;
        }
        return false;
    }

    private static void DBPasswordChange(Session DBsession, String username, String password) {
        String encryptedPassword = EncryptUtil.EncryptSHA256(password);
        YuruUserEntity user = DBsession.get(YuruUserEntity.class, username);
        user.setPassword(encryptedPassword);
        DBsession.update(user);
    }

    public static String ChangePassword(String username, String oldPassword, String newPassword) {
        if(oldPassword.equals(newPassword)){
            return "#same_password";
        }

        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();

        try{
            boolean duplicatePassword = false;
            duplicatePassword = CheckDuplicatePwd(DBsession, username, oldPassword);
            if(duplicatePassword) {
                transaction.commit();
                return "#wrong_password";
            }
            if(!duplicatePassword) {
                DBPasswordChange(DBsession, username, newPassword);
                transaction.commit();
                return "#set_success";
            }
            return "#other_wrong";
        } catch(Exception ex) {
            LogUtil.Log(String.format("Request for login but exception occurred, service rollback, %s", ex),
                    PasswordService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "#exception_occurred";
        }
    }
}
