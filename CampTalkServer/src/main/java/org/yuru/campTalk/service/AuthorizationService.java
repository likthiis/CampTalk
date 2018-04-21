package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.GlobalConfigContext;
import org.yuru.campTalk.entity.YuruSessionEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.*;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

/**
 * Author: Rinkako
 * Date  : 2018/4/21
 * Usage : 授权服务处理类
 */
public class AuthorizationService {

    /**
     * 处理服务授权token获取服务
     * @param uid 用户唯一id
     * @param rawPassword 密码（未加密字符串，安全性依靠信道的可靠性）
     * @return 授权token，如果登录失败，则返回一个以#开头的错误原因字符串
     */
    public static String Login(String uid, String rawPassword) {
        // 获取当前线程的Hibernate会话
        Session session = HibernateUtil.GetLocalSession();
        // 开启数据库事务
        Transaction transaction = session.beginTransaction();
        try {
            // 把密码明文转成数据库的密文
            String encryptedPassword = EncryptUtil.EncryptSHA256(rawPassword);
            // 拿用户记录
            YuruUserEntity rae = session.get(YuruUserEntity.class, uid);
            // 如果用户不存在或者被ban了就返回用户不存在的消息
            if (rae == null || rae.getStatus() != 0) {
                transaction.commit();
                return "#user_not_valid";
            }
            // 对一下密码，如果不对就返回密码错误消息
            else if (!rae.getPassword().equals(encryptedPassword)) {
                transaction.commit();
                return "#password_invalid";
            }
            // 检查现存的该用户的活跃授权会话，如果有就毁掉
            List<YuruSessionEntity> oldRseList = session.createQuery(String.format("FROM YuruSessionEntity WHERE uid = '%s' AND destroy_timestamp = NULL", uid)).list();
            Timestamp currentTS = TimestampUtil.GetCurrentTimestamp();
            for (YuruSessionEntity rse : oldRseList) {
                if (rse.getUntilTimestamp().after(currentTS)) {
                    rse.setDestroyTimestamp(currentTS);
                }
            }
            // 创建一个新的授权会话
            String tokenId = String.format("AUTH_%s_%s", uid, UUID.randomUUID());
            YuruSessionEntity rse = new YuruSessionEntity();
            long createTs = System.currentTimeMillis();
            rse.setLevel(rae.getLevel());
            rse.setToken(tokenId);
            rse.setUid(uid);
            rse.setCreateTimestamp(new Timestamp(createTs));
            // 设置token自动过期时间
            if (GlobalConfigContext.AUTHORITY_TOKEN_VALID_SECOND != 0) {
                rse.setUntilTimestamp(new Timestamp(createTs + 1000 * GlobalConfigContext.AUTHORITY_TOKEN_VALID_SECOND));
            }
            session.save(rse);
            // 提交事务到数据库
            transaction.commit();
            // 返回授权的token，今后客户端就带着这个token来请求服务
            return tokenId;
        }
        catch (Exception ex) {
            LogUtil.Log(String.format("Request for auth but exception occurred (%s), service rollback, %s", uid, ex),
                    AuthorizationService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "#exception_occurred";
        }
        finally {
            // 关掉Hibernate会话
            HibernateUtil.CloseLocalSession();
        }
    }
}
