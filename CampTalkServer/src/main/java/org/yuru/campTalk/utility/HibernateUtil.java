package org.yuru.campTalk.utility;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Common methods for hibernate.
 */
//HibernateUtil辅助类
@Component
public class HibernateUtil {
    /**
     * Hibernate session factory instance, thread safe.
     */
    //蛰伏框架的会话的工厂实例(在线程安全条件下)
    private static SessionFactory sessionFactory;


    /**
     * session object in thread local, thread safe.
     */
    //本地线程中保存的会话对象。(在线程安全条件下)
    private static ThreadLocal session = new ThreadLocal();

    /**
     * Construct hibernate utility, binding session factory.
     * @param sessionFactory session factory instance
     */
    //修建蛰伏框架的基础设施，将其与会话的工厂实例绑定在一起。
    @Autowired(required = true)
    public HibernateUtil(SessionFactory sessionFactory) {
        HibernateUtil.sessionFactory = sessionFactory;
    }

    /**
     * Get session factory, SessionFactory is thread safe.
     * @return session factory instance
     */
    //得到会话工厂，并且该会话工厂已经保全线程安全。
    private static SessionFactory GetSessionFactory() {
        return HibernateUtil.sessionFactory;
    }

    /**
     * Get session for hibernate in this thread.
     * @return hibernate session instance
     */
    @SuppressWarnings("unchecked")
    public static Session GetLocalSession() {
        Session s = (Session) session.get();
        if (s == null) {
            s = HibernateUtil.GetSessionFactory().openSession();
            HibernateUtil.session.set(s);
        }
        return s;
    }

    /**
     * Close active session in this thread.
     */

    //把线程内的活跃的会话处理掉。
    @SuppressWarnings("unchecked")
    public static void CloseLocalSession() {
        try {  //安全模式。
            Session s = (Session) session.get();
            if (s != null) {
                if (s.isOpen()) {
                    s.close();
                }
                session.set(null);
            }
        }
        catch (Exception ex) {
            LogUtil.Echo("Close hibernate session failed, " + ex,
                    HibernateUtil.class.getName(), LogLevelType.ERROR);
        }
    }

    public static SessionFactory getSessionFactory(){
        return sessionFactory;
    }
}