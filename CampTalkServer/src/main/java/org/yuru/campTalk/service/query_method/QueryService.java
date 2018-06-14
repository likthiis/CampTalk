package org.yuru.campTalk.service.query_method;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.entity.YuruAuthEntity;
import org.yuru.campTalk.entity.YuruFriendEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.service.friend_method.FriendRequestService;
import org.yuru.campTalk.service.friend_method.ShowSearchUser;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;

import java.sql.Timestamp;
import java.util.ArrayList;
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
            transaction.commit();
            if(auth.size() > 0) {
                if(auth.get(0).getToken().equals(token)) {
                    return true;
                } else {
                    return false;
                }
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

    public static String SearchUidByToken(String token) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try {
            String query = String.format("from YuruAuthEntity as auth where auth.token = '%s'", token);
            List<YuruAuthEntity> auth = DBsession.createQuery(query).list();
            transaction.commit();
            if(auth.size() > 0) {
                return auth.get(0).getUid();
            } else {
                return "can_not_found";
            }
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, QueryService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "exception_error";
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }

    public static void DeleteTokenByUid(String userId) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try {
            String query = String.format("delete from YuruAuthEntity as auth where auth.uid = '%s'", userId);
            Query queryUpdate = DBsession.createQuery(query);
            int ret = queryUpdate.executeUpdate();
            if (ret != 0) {
                String test = String.format("用户%s的口令清除", userId);
                System.out.println(test);
            }
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, QueryService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }

    public static ArrayList<String> getFriendsList(String userId) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        ArrayList<String> friendsName = new ArrayList<>();
        try {
            String query = String.format("from YuruFriendEntity as friend where friend.name1 = '%s' or friend.name2 = '%s'", userId, userId);
            List<YuruFriendEntity> friends = DBsession.createQuery(query).list();
            if(friends.size() > 0) {
                for(YuruFriendEntity o : friends) {
                    if(!o.getName1().equals(userId)) {
                        friendsName.add(o.getName1());
                    } else {
                        friendsName.add(o.getName2());
                    }
                }
            }
            transaction.commit();
            return friendsName;
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, QueryService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            friendsName.add("rollback_wrong");
            return friendsName;
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }

    public static String getTimeByToken(String token) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try {
            String query = String.format("from YuruAuthEntity as auth where auth.token = '%s'", token);
            List<YuruAuthEntity> auths = DBsession.createQuery(query).list();
            transaction.commit();
            if(auths.size() > 0) {
                Timestamp timestamp = auths.get(0).getDestroyTimestamp();
                return timestamp.toString();
            } else {
                return "sql_error";
            }
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("查找过程出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, QueryService.class.getName(), LogLevelType.ERROR, "");
            transaction.rollback();
            return "rollback_wrong";
        } finally {
            // 关闭数据库交互
            HibernateUtil.CloseLocalSession();
        }
    }
}
