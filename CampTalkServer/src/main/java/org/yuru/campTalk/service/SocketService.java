package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;

import javax.servlet.http.HttpSession;

public class SocketService {

    public static String LoginUsingSession(HttpSession session, String userId) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try {
            System.out.println("userId is " + userId);
            session.setAttribute("userId", userId);
            System.out.println("now the session's userId is " + session.getAttribute("userId"));
            // database commit


            return "#websocket_login_success";
        } catch (Exception ex) {
            LogUtil.Log(String.format("Request for login but exception occurred, service rollback, %s", ex),
                    SocketService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "#exception_occurred";
        }
    }
}
