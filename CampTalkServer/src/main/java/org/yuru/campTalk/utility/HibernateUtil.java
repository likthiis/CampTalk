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
    //从这个线程中获得会话，并返回会话的实例(里面应该有相关的数据)。

    //告诉编译器出现警告也要跳过。
    @SuppressWarnings("unchecked")
    public static Session GetLocalSession() {
        Session s = (Session) session.get(); //会话获得。(好像是组键值对)
        if (s == null) {  //如果这个会话是不存在的。
            s = HibernateUtil.GetSessionFactory().openSession(); //就调用上面的获得会话工厂的实例，并将里面的实例提取出来。
            HibernateUtil.session.set(s); //设置一下里面的数据。
        }
        return s;
    }

    //(20180418)get和set还没有被写出来的样子...

    /**
     * Close active session in this thread.
     */

    //把线程内的活跃的会话处理掉。
    @SuppressWarnings("unchecked")
    public static void CloseLocalSession() {
        try {  //安全模式。
            Session s = (Session) session.get(); //获得对话
            if (s != null) {  //确实有会话。
                if (s.isOpen()) { //而且还是开着的。
                    s.close(); //就关掉它。
                }
                session.set(null); //处理掉，内存减负。
            }
        }
        catch (Exception ex) {
            LogUtil.Echo("Close hibernate session failed, " + ex,
                    HibernateUtil.class.getName(), LogLevelType.ERROR); //应急手段。
        }
    }

    public static SessionFactory getSessionFactory(){
        return sessionFactory;
    }
}