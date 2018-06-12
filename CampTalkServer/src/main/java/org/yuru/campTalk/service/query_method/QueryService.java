package org.yuru.campTalk.service.query_method;

import com.google.gson.Gson;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.springframework.transaction.annotation.Transactional;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.entity.YuruAuthEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.service.friend_method.FriendRequestService;
import org.yuru.campTalk.service.friend_method.ShowSearchUser;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;

import java.io.IOException;
import java.util.List;

/**
 * Author: Likthiis
 * Date  : 2018/6/3
 * Usage : Concrete logic for querying information.
 */
public class QueryService {
    public static ReturnModel QueryExistence(String uid) {
        ReturnModel model = new ReturnModel();
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();

        try {
            String query = String.format("from YuruUserEntity as user where user.id = '%s'", uid);
            List<YuruUserEntity> list = DBsession.createQuery(query).list();
            if(list.size() > 0) {
                if(list.get(0).getId().equals(uid)) {
                    model.successDeal("user_existence");
                } else {
                    model.successDeal("user_inexistence");
                }
            } else {
                model.successDeal("user_inexistence");
            }
            transaction.commit();
            return model;
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, QueryService.class.getName(), LogLevelType.ERROR, "");
            ReturnModelHelper.ExceptionResponse(model, exception);
            transaction.rollback();
            return model;
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }

    // 查询并返回用户的具体信息
    public static ReturnModel SearchUser(String uid) {
        ReturnModel returnModel = new ReturnModel();
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();

        try {
            String query = String.format("from YuruUserEntity as user where user.id = '%s'", uid);
            List<YuruUserEntity> list = DBsession.createQuery(query).list();
            if(list.size() > 0) {
                YuruUserEntity yuruUserEntity = DBsession.get(YuruUserEntity.class, uid);
                ShowSearchUser showSearchUser = new ShowSearchUser(yuruUserEntity);
                returnModel.successDeal("success_query");
                returnModel.setRequest(showSearchUser);
            } else {
                returnModel.successDeal("can_not_find");
            }
            transaction.commit();
            return returnModel;
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, FriendRequestService.class.getName(), LogLevelType.ERROR, "");
            returnModel.specialDeal();
            transaction.rollback();
            return returnModel;
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }

    public static boolean SearchToken(String token) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();

        try {
            String query = String.format("from YuruAuthEntity as auth where auth.token = '%s'", token);
            List<YuruAuthEntity> auth = DBsession.createQuery(query).list();
            if(auth.size() > 0) {
                return true;
            }
            return false;
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, QueryService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return false;
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }
}
