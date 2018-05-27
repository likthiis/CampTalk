package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.dto.FriendRequestModel;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.entity.YuruFriendEntity;
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
            DBsession.close();
            returnModel.successDeal("friend_transaction_success");
            return returnModel;
        } catch (Exception ex) {
            // 异常处理
            String exception = String.format("Request for auth but exception occurred, service rollback, %s", ex);
            LogUtil.Log(exception, FriendRequestService.class.getName(), LogLevelType.ERROR, "");
            returnModel.specialDeal();
            return returnModel;
        } finally {
            HibernateUtil.CloseLocalSession();
        }
    }
}
