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
import java.io.IOException;
import java.sql.Timestamp;
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
            String test = String.format("the sessionId is %s and the uid is %s", session.getId(), userId);
            System.out.println(test);

            // 将userid与session以键值对形式保存
            sessionMap.put(userId, session);
            addOnlineCount();
            System.out.println("有新连接加入！当前在线人数为" + getOnlineCount() + "人");

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
    public void close(@PathParam("userId")String userId, Session session) { // 关闭websocket
        try {
            // test
            String test = String.format("现在移除用户名为%s的session", userId);
            System.out.println(test);
            // 将键值对移除
            sessionMap.remove(userId);

            // 将token从数据库中移除
            QueryService.DeleteTokenByUid(userId);

            subOnlineCount();
            System.out.println("有一连接关闭！当前在线人数为" + getOnlineCount() + "人");
//            this.sessions.remove(session);
//            this.usernames.remove(this.uid);
//            String leaveMsg = this.username + "已经离开聊天室";
//            MessageUtil message = new MessageUtil(leaveMsg, this.usernames);
//            sessionMap.remove(this.uid);
//            this.broadcast(this.sessions, message.getMessageToJson());
//            System.out.println("websocket is closed.");

        } catch (Exception e) {
            e.printStackTrace();
        }
        //webSocketSet.remove(this);
    }

    private boolean Verification (Session session, String token, String userId) {
        Boolean rightToken = QueryModule.checkToken(token);
        String uid = QueryModule.checkUidByToken(token);
        int valiateStatus = QueryModule.checkTimeByToken(token);
        Boolean isTrue = false;

        try {
            // 对照token
            if (!rightToken) {
                session.getBasicRemote().sendText("invaild_token");
                isTrue = false;
            } else {
                System.out.println("token内容正确");
                isTrue = true;
            }

            // 对照uid
            if (!(uid.equals("can_not_found") && uid.equals("exception_error")) && userId.equals(uid)) {
                Session existenceSession = sessionMap.get(uid);
                if (existenceSession.equals(session)) {
                    // 是同一个session，证明了是该用户的链接
                    System.out.println("用户名正确");
                    isTrue = true;
                }
            } else {
                if (uid.equals("can_not_found")) {
                    session.getBasicRemote().sendText("invaild_token");
                    isTrue = false;
                }
                if (uid.equals("exception_error")) {
                    session.getBasicRemote().sendText("invaild_token");
                    isTrue = false;
                }
            }

            // token过期验证
            if (valiateStatus == 1) {
                session.getBasicRemote().sendText("token_check_sql_wrong");
                isTrue = false;
            }
            if (valiateStatus == 2) {
                session.getBasicRemote().sendText("token_check_rollback_wrong");
                isTrue = false;
            }
            if (valiateStatus == 3) {
                session.getBasicRemote().sendText("token_check_overdue");
                isTrue = false;
            }
            if (valiateStatus == 4) {
                System.out.println("token未过期");
                isTrue = true;
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return isTrue;
    }

    @OnMessage
    public void message(@PathParam("userId")String userId, Session session, String message) {
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

            Boolean legal = Verification(session, token, userId);
            if(!legal) {
                return;
            }

            // 返回好友列表
            if (session.isOpen() && action.equals("showmyfriends")) {
                QueryModule.showFriends(session, userId);
            }

            // 查询用户
            if (session.isOpen() && action.equals("usersearch")) {
                QueryModule.userSearch(session, (String)requestModel.getReq());
            }

            // 好友请求(只是测试了链接与数据库插入功能)
            if (session.isOpen() && action.equals("friendrequest")) {
                FriendModule.friendRequest(session,message);
                return;
            }

            if (session.isOpen() && action.equals("singlechat")) {
                WebSocketService.singleChat(session, message, sessionMap);

            }


//            // 将websocket的session与其用户名存入键值对。
//            if (session.isOpen() && message.substring(0, 3).equals("uid")) {
//                // 如果这是uid的传输字段，那么将对uid及其session做一个处理。
//                String _uid = message.substring(4);
//                sessionMap.put(_uid, session);
//                return;
//            }




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
