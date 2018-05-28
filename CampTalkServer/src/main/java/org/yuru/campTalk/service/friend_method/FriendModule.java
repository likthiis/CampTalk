package org.yuru.campTalk.service.friend_method;

import net.sf.json.JSONObject;
import org.yuru.campTalk.dto.FriendRequestModel;
import org.yuru.campTalk.dto.ReturnModel;

import javax.websocket.Session;
import java.io.IOException;

public class FriendModule {
    // 好友请求功能函数
    public static void friendRequest(Session session, String message) {
        String friendRequest = message.substring(14);
        JSONObject JSONmessage = JSONObject.fromObject(friendRequest);
        FriendRequestModel friendRe = (FriendRequestModel) JSONObject.toBean(JSONmessage, FriendRequestModel.class);

        // 一个类已经建立起来，下面是数据库处理的内容
        ReturnModel returnModel = new ReturnModel();
        returnModel = FriendRequestService.dealRequest(friendRe);

        try {
            // 获得返回类，将其转化成JSON发还给客户端
            session.getBasicRemote().sendText("return:" + returnModel.getMessageToJson());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void userSearch(Session session, String message) {
        ReturnModel returnModel = new ReturnModel();
        message = message.substring(11);
        returnModel = FriendRequestService.SearchFriend(message);

        try {
            // 获得返回类，将其转化成JSON发还给客户端
            session.getBasicRemote().sendText("return:" + returnModel.getMessageToJson());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
