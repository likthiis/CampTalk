package org.yuru.campTalk.service.query_method;

import com.google.gson.Gson;
import org.springframework.transaction.annotation.Transactional;
import org.yuru.campTalk.dto.ReturnModel;

import javax.websocket.Session;
import java.io.IOException;

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

    public static boolean checkToken(Session session, String token) {
        boolean judge = false;
        judge = QueryService.SearchToken(token);
        return judge;
    }
}
