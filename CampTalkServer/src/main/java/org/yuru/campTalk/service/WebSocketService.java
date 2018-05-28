package org.yuru.campTalk.service;

import net.sf.json.JSONObject;
import org.yuru.campTalk.dto.FriendRequestModel;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.SingleChatModel;

import javax.websocket.Session;
import java.io.IOException;
import java.util.Map;

public class WebSocketService {

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

    public static void singleChat(Session session, String message, Map<String, Session> sessionMap) {
        // 单聊
        // 截取可用的JSON字段
        message = message.substring(11);

        // 将接受到的websocket内的信息存进实体，并操作这个实体来进行下一步的处理
        JSONObject JSONmessage = JSONObject.fromObject(message);
        SingleChatModel msg = (SingleChatModel) JSONObject.toBean(JSONmessage, SingleChatModel.class);
        // test
        System.out.println("在单聊框架内，我们得到如下消息：" + msg.getMessageToJson());

        // 现在，在没有使用数据库的情况下，单聊的模式已经实现。
        msg.setContent(msg.getContent());
        message = msg.getMessageToJson();
        Session target = sessionMap.get(msg.getReceiver());

        try {
            target.getBasicRemote().sendText(message);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
