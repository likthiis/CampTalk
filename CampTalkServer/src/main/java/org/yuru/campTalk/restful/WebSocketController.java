package org.yuru.campTalk.restful;

import com.google.gson.Gson;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.WebSocket.GetHttpSessionConfigurator;
import org.yuru.campTalk.dto.RequestModel;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.service.friend_method.FriendModule;
import org.yuru.campTalk.service.friend_method.FriendRequestService;
import org.yuru.campTalk.service.WebSocketService;
import org.yuru.campTalk.service.query_method.QueryModule;
import org.yuru.campTalk.service.query_method.QueryService;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ServerEndpoint(value = "/websocket/{userId}", configurator = GetHttpSessionConfigurator.class)
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
    public void onOpen(@PathParam("userId")String userId, Session session, EndpointConfig config) { // 打开websocket
        try {
            // test
            System.out.println("the session is : " + session.getId());
            System.out.println("the uid is : " + userId);

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

            addOnlineCount();
            System.out.println("有新连接加入！当前在线人数为" + getOnlineCount() + "人");
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
            subOnlineCount();
            System.out.println("有一连接关闭！当前在线人数为" + getOnlineCount() + "人");
        } catch (Exception e) {
            e.printStackTrace();
        }
        //webSocketSet.remove(this);
    }

    @OnMessage
    public void message(Session session, String message) {
        System.out.println(message);
        try {
            // 测试用
            if (session.isOpen() && message.equals("test")) {
                String backMsg = "从服务端返回的消息";
                session.getBasicRemote().sendText(backMsg);
                return;
            }

            // 从客户端会发过来一个结构体
            RequestModel requestModel = new Gson().fromJson(message, RequestModel.class);
            String action = requestModel.getAction();
            String token = requestModel.getToken();
            // 对照token

            Boolean rightToken = QueryModule.checkToken(session, token);
            if(!rightToken) {
                session.getBasicRemote().sendText("invaild_token");
                return;
            }

            // 查询用户
            if (session.isOpen() && action.equals("usersearch")) {
                QueryModule.userSearch(session, (String)requestModel.getReq());
            }

            // 将websocket的session与其用户名存入键值对。
            if (session.isOpen() && message.substring(0, 3).equals("uid")) {
                // 如果这是uid的传输字段，那么将对uid及其session做一个处理。
                String uid = message.substring(4);
                sessionMap.put(uid, session);
                return;
            }

            // 好友请求(只是测试了链接与数据库插入功能)
            if (session.isOpen() && action.equals("friendrequest")) {
                // 如果这是好友请求，那么将进行处理
                FriendModule.friendRequest(session,message);
                return;
            }

            if (session.isOpen() && action.equals("singlechat")) {
                WebSocketService.singleChat(session, message, sessionMap);

            }


        } catch (Exception e) {
            e.printStackTrace();
        }
    }

//                    List<Session> sessionPrivateList = new ArrayList<Session>();
//                    for (int i = 0; i < msg.getTo().size(); i++) {
//                        String userMessage = msg.getTo().get(i);
//                        sessionPrivateList.add(sessionMap.get(userMessage));
//                    }
//                    sessionPrivateList.add(sessionMap.get(msg.getFrom()));
//                    this.broadcast(sessionPrivateList, msg.getMessageToJson());
//                } else if (msg.getType() == 2) { // 群聊
//                    this.broadcast(this.sessions, msg.getMessageToJson());
//                }

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
