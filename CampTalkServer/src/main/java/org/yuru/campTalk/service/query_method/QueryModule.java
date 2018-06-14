package org.yuru.campTalk.service.query_method;

import com.google.gson.Gson;
import org.springframework.transaction.annotation.Transactional;
import org.yuru.campTalk.dto.ReturnModel;

import javax.websocket.Session;
import java.io.IOException;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

@Transactional
public class QueryModule {
    public static void userSearch(Session session, String uid) {
        ReturnModel returnModel = null;
        returnModel = QueryService.SearchUser(uid);
        try {
            // 获得返回类，将其转化成JSON发还给客户端
            session.getBasicRemote().sendText(new Gson().toJson(returnModel));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static boolean checkToken(String token) {
        boolean judge = false;
        judge = QueryService.SearchToken(token);
        return judge;
    }

    public static String checkUidByToken(String token) {
        String name;
        name = QueryService.SearchUidByToken(token);
        return name;
    }

    public static void showFriends(Session session, String userId) {
        ReturnModel returnModel = new ReturnModel();
        ArrayList<String> friends = QueryService.getFriendsList(userId);

        if(friends.get(0).equals("rollback_wrong")) {
            returnModel.setStatus("get_fail");
        } else if(friends.equals(null)) {
            returnModel.setStatus("friends_null");
        } else {
            returnModel.setStatus("get_success");
            returnModel.setRequest(friends);
        }

        try {
            // 获得返回类，将其转化成JSON发还给客户端
            session.getBasicRemote().sendText(new Gson().toJson(returnModel));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static int checkTimeByToken(String token) {
        String ret = QueryService.getTimeByToken(token);
        if (ret.equals("sql_error")) {
            return 1;
        } else if (ret.equals("rollback_wrong")) {
            return 2;
        }
        Timestamp desTimestamp = Timestamp.valueOf(ret);
        if (desTimestamp.after(new Timestamp(new Date().getTime()))) {
            return 3; // 3是过期提示
        }
        return 4; // 4是无问题
    }
}
