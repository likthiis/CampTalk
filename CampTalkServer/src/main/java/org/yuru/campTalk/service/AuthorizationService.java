package org.yuru.campTalk.service;


import org.hibernate.Session;
import org.hibernate.Transaction;
import org.springframework.web.socket.WebSocketSession;
import org.yuru.campTalk.GlobalConfigContext;
import org.yuru.campTalk.entity.YuruSessionEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.*;

import javax.servlet.http.HttpSession;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

/**
 * Author: Rinkako
 * Date  : 2018/4/21
 * Usage : Authorize registered users to connect with server.
 */
public class AuthorizationService {
    public static int VerificationByPassword(String uid, String rawPassword,Session DBsession) {
        String encryptedPassword = EncryptUtil.EncryptSHA256(rawPassword);
        // Get the record of user.
        YuruUserEntity user = DBsession.get(YuruUserEntity.class, uid);
        // Tell the client that user is inexistence.
        if (user == null) {
            return 1;
        }
        // Tell the client that user is banned.
        if (user.getStatus() != 0) {
            return 2;
        }
        // Compare the password,and tell the client that password is invaild if it is.
        else if (!user.getPassword().equals(encryptedPassword)) {
            return 3;
        }
        return 0;
    }

    public static Timestamp SetUserLoginAndSave(String uid, Session DBsession) {
        String tokenId = String.format("AUTH_%s_%s", uid, UUID.randomUUID());
        YuruSessionEntity loginSession = new YuruSessionEntity();
        long createTimeStamp = System.currentTimeMillis();
        loginSession.setLevel(loginSession.getLevel());
        loginSession.setToken(tokenId);
        loginSession.setUid(uid);
        loginSession.setCreateTimestamp(new Timestamp(createTimeStamp));
        Timestamp untilTimeStamp = new Timestamp(System.currentTimeMillis() + 1000 * GlobalConfigContext.AUTHORITY_TOKEN_VALID_SECOND);
        // Set the deadline of session.
        loginSession.setUntilTimestamp(untilTimeStamp);
        DBsession.save(loginSession);
        return untilTimeStamp;
    }

    public static void RuinPassToken(String uid, Session DBsession) {
        String query = String.format("FROM YuruSessionEntity WHERE uid = '%s' AND destroy_timestamp = NULL", uid);
        List<YuruSessionEntity> oldUserSessions = DBsession.createQuery(query).list();
        Timestamp currentTimestamp = TimestampUtil.GetCurrentTimestamp();
        for (YuruSessionEntity rse : oldUserSessions) {
            if (rse.getUntilTimestamp().after(currentTimestamp)) {
                rse.setDestroyTimestamp(currentTimestamp);
            }
        }
    }

    public static void SocketSetAttribute(String uid,Timestamp untilTimeStamp,HttpSession socketSession) {
        System.out.println("userId is " + uid);

        socketSession.setAttribute("userId", uid);
        socketSession.setAttribute("untilTime", untilTimeStamp);
        System.out.println("now the session's userId is " + socketSession.getAttribute("userId"));
        System.out.println("now the session's timestamp is " + socketSession.getAttribute("untilTime"));
    }

    /**
     * Using token to achieve the login function.
     * @param uid is the only one identifier of user
     * @param rawPassword will be showed in encryption status
     * @return token or a string beginning with "#" if failing to login
     */
    public static String Login(HttpSession socketSession, String uid, String rawPassword) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try {
            int judgeException = VerificationByPassword(uid, rawPassword, DBsession);
            switch(judgeException) {
                case 1:{
                    transaction.commit();
                    return "#user_not_valid";
                }
                case 2:{
                    transaction.commit();
                    return "#blocked_account";
                }
                case 3:{
                    transaction.commit();
                    return "#password_invalid";
                }
            }
            // Ruin the existing session in database,if the moment in its record is after the moment of login on this occasion.
            RuinPassToken(uid,DBsession);
            // Create a new authorized session.
            Timestamp untilTimeStamp = SetUserLoginAndSave(uid,DBsession);
            // Transaction commit.
            SocketSetAttribute(uid,untilTimeStamp,socketSession);
            transaction.commit();
            return "#login_success";
        }
        catch (Exception ex) {
            String exception = String.format("Request for auth but exception occurred (%s), service rollback, %s", uid, ex);
            LogUtil.Log(exception, AuthorizationService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "#exception_occurred";
        }
        finally {
            // Close the session of hibernate.
            HibernateUtil.CloseLocalSession();
        }
    }
}
