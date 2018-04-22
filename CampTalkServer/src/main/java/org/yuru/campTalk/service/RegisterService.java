package org.yuru.campTalk.service;


import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.entity.YuruSessionEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.EncryptUtil;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;

import javax.persistence.criteria.CriteriaBuilder;
import java.sql.Timestamp;
import java.util.List;

/**
 * Author: likthiis
 * Date  : 2018/4/22
 * Usage : 注册服务处理类
 */
public class RegisterService {

    /**
     * 注册服务
     */

    /**
     * 将uid和加密过的password写入camptalk中的yuru_user中
     * 具体描述：
     * 1.根据用户提供的用户名和密码建立实例，并存入数据库；
     * 2.uid是用户名，username是昵称，uid不可重复username可重复；
     * 3.目前，地址定位、头像初定义功能尚未完成。
     */
    public static String Register(String uid, String rawPassword) {
        // 获取当前线程的Hibernate会话
        Session session = HibernateUtil.GetLocalSession();
        // 开启数据库事务
        Transaction transaction = session.beginTransaction();

        try{
            // 把密码明文转成数据库的密文
            String encryptedPassword = EncryptUtil.EncryptSHA256(rawPassword);

            YuruUserEntity user = new YuruUserEntity();

            // 查重(uid重复)
            YuruUserEntity repeat = session.get(YuruUserEntity.class, uid);
            if(repeat != null) {
                // 完成事务
                transaction.commit();
                // 返回注册完成的消息
                return "#duplicate_name";
            }

            user.setId(uid);
            // 昵称先与用户名同名
            user.setUsername(uid);
            user.setPassword(encryptedPassword);
            user.setStatus(0);
            user.setLevel(1);
            user.setCreatetimestamp(new Timestamp(System.currentTimeMillis()));
            user.setLocation("Kamihama");

            // 存入数据库
            session.save(user);
            // 完成事务
            transaction.commit();
            session.close();
            // 返回注册完成的消息
            return "#login_success";

        }catch (Exception ex){
            LogUtil.Log(String.format("Request for login but exception occurred, service rollback, %s", ex),
                    AuthorizationService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "#exception_occurred";
        }
    }
}
