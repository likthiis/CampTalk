package org.yuru.campTalk.restful;

import net.sf.json.JSONObject;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.WebSocket.GetHttpSessionConfigurator;
import org.yuru.campTalk.dto.FriendRequestModel;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.service.FriendRequestService;
import org.yuru.campTalk.utility.MessageUtil;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ServerEndpoint(value = "/websocket", configurator = GetHttpSessionConfigurator.class)
@RestController
public class WebSocketController {
    private static int onlineCount = 0;
    private static List<String> usernames = new ArrayList<String>();
    private static List<Session> sessions = new ArrayList<Session>();

    // 用来记录用户名和该session进行绑定
//    private Session session;
    private String uid;
    private static Map<String, Session> sessionMap = new HashMap<String, Session>();

    @OnOpen
    public void onOpen(Session session,EndpointConfig config) { // 打开websocket
        try {
            // test
            System.out.println("the session is : " + session.getId());

//            String sessionMsg = session.getQueryString();
//            if(sessionMsg == null) {
//                System.out.println(session);
//            } else {
//                this.uid = sessionMsg.split("=")[1];
//            }

            // 以下实现广播欢迎信息。
//            String welcome = "欢迎" + this.username + "加入聊天室";
//            MessageUtil message = new MessageUtil(welcome, usernames);
//            this.broadcast(this.sessions, message.getMessageToJson());

//            addOnlineCount();
//            System.out.println("有新连接加入！当前在线人数为" + getOnlineCount() + "人");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

//    private void broadcast(List<Session> sessions, String messageToJson) {
//        if(sessions.size() > 0) {
//            for(int i = 0;i < sessions.size();i++) {
//                try {
//                    sessions.get(i).getBasicRemote().sendText(messageToJson);
//                } catch (IOException e) {
//                    System.out.println("WebSocketServer.java broadcast method, 广播失败");
//                    e.printStackTrace();
//                }
//            }
//        }
//    }

    @OnClose
    public void close(Session session) { // 关闭websocket
        try {
            this.sessions.remove(session);
            this.usernames.remove(this.uid);
//            String leaveMsg = this.username + "已经离开聊天室";
//            MessageUtil message = new MessageUtil(leaveMsg, this.usernames);
            sessionMap.remove(this.uid);
//            this.broadcast(this.sessions, message.getMessageToJson());
//            System.out.println("websocket is closed.");
//            subOnlineCount();
//            System.out.println("有一连接关闭！当前在线人数为" + getOnlineCount() + "人");
        } catch (Exception e) {
            e.printStackTrace();
        }
        //webSocketSet.remove(this);
    }

    @OnMessage
    public void message(Session session, String message) {
        // 将websocket的session与其用户名存入键值对。
        if(message.substring(0, 3).equals("uid")) {
            // 如果这是uid的传输字段，那么将对uid及其session做一个处理。
            try {
                String uid = message.substring(4);
                sessionMap.put(uid, session);
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 我们将通过websocket来处理好友的一些事务
        // 好友请求
        // 我们假定好友请求的格式由一个类来承担
        if(message.substring(0, 13).equals("friendrequest")) {
            // 如果这是好友请求，那么将进行处理
            try {
                String friendRequest = message.substring(14);
                JSONObject JSONmessage = JSONObject.fromObject(friendRequest);
                FriendRequestModel friendRe = (FriendRequestModel) JSONObject.toBean(JSONmessage, FriendRequestModel.class);

                // 一个类已经建立起来，下面是数据库处理的内容
                ReturnModel returnModel = new ReturnModel();
                returnModel = FriendRequestService.dealRequest(friendRe);

                // 获得返回类，将其转化成JSON发还给客户端
                session.getBasicRemote().sendText(returnModel.getMessageToJson());
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


        try {
            // message是从客户端传过来的，将其进行JSON的解码，好利用其中的数据
            System.out.println(message);

            if (session.isOpen()) {
                // 将接受到的websocket内的信息存进实体，并操作这个实体来进行下一步的处理
                JSONObject JSONmessage = JSONObject.fromObject(message);
                MessageUtil msg = (MessageUtil) JSONObject.toBean(JSONmessage, MessageUtil.class);
                if (msg.getType() == 1) { // 单聊
                    // test
                    System.out.println("在单聊框架内，我们得到如下消息：" + msg.getMessageToJson());

                    // test：从这里，服务端将发一个结构体给客户端，给这一次登录的客户端
                    // 现在，在没有使用数据库的情况下，单聊的模式已经实现。
                    msg.setContent(msg.getContent());
                    message = msg.getMessageToJson();
                    Session target = sessionMap.get(msg.getReceiver());
                    target.getBasicRemote().sendText(message);


//                    List<Session> sessionPrivateList = new ArrayList<Session>();
//                    for (int i = 0; i < msg.getTo().size(); i++) {
//                        String userMessage = msg.getTo().get(i);
//                        sessionPrivateList.add(sessionMap.get(userMessage));
//                    }
//                    sessionPrivateList.add(sessionMap.get(msg.getFrom()));
//                    this.broadcast(sessionPrivateList, msg.getMessageToJson());
                } else if (msg.getType() == 2) { // 群聊
//                    this.broadcast(this.sessions, msg.getMessageToJson());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnError
    public void onError(Session session, Throwable error) {
        System.out.println("发生错误");
        error.printStackTrace();
    }

    public static synchronized int getOnlineCount() {
        return onlineCount;
    }

    public static synchronized void addOnlineCount() {
        WebSocketController.onlineCount++;
    }

    public static synchronized void subOnlineCount() {
        WebSocketController.onlineCount--;
    }
}
