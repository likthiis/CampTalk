package org.yuru.campTalk.service.friend_method;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.dto.FriendRequestModel;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.entity.YuruFriendEntity;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.HibernateUtil;
import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.LogUtil;

public class FriendRequestService {

    public static ReturnModel dealRequest(FriendRequestModel friendRe) {
        ReturnModel returnModel = new ReturnModel();
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();

        try {
            // 处理好友请求类的逻辑
            String myUid = friendRe.getMyUid();
            String itsUid = friendRe.getItsUid();

            YuruFriendEntity yuruFriendEntity = new YuruFriendEntity();
            yuruFriendEntity.setName1(myUid);
            yuruFriendEntity.setName2(itsUid);

            // 将好友联系存入数据库
            DBsession.save(yuruFriendEntity);

            // 业务收尾
            transaction.commit();
            returnModel.successDeal("friend_transaction_success");
            return returnModel;
        } catch (Exception ex) {
            // 异常处理：在回滚事务后，将异常情况告知客户端
            String exception = String.format("好友请求出现问题，存在异常： %s", ex);
            LogUtil.Log(exception, FriendRequestService.class.getName(), LogLevelType.ERROR, "");
            returnModel.specialDeal();
            transaction.rollback();
            return returnModel;
        } finally {
            HibernateUtil.CloseLocalSession();
        }
    }

}
