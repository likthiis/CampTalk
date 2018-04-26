package org.yuru.campTalk.restful;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.socket.TextMessage;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.AuthorizationService;
import org.yuru.campTalk.service.SocketService;
import org.yuru.campTalk.websocket.MyWebSocketHandler;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/camp")
public class SocketController {

    @Autowired
    MyWebSocketHandler handler;

    /**
     * Login to Server.
     * @param session
     * @param userId
     * @return ReturnModel
     */
    @RequestMapping("/login/{userId}")
    @ResponseBody
    @Transactional
    public ReturnModel loginUsingSession(HttpSession session, @RequestParam(value="uid")String userId) {
        ReturnModel loginModel = new ReturnModel();
        try {
            // handle missing params
            List<String> missingParams = new ArrayList<>();
            if (session == null) {
                missingParams.add("session");
            }
            if (userId == null) {
                missingParams.add("uid");
            }
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            // logic
            String jsonifyResponse = SocketService.LoginUsingSession(session, userId);
            // return
            ReturnModelHelper.StandardResponse(loginModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(loginModel, e.getClass().getName());
        }
        return loginModel;
    }

    /**
     * MessageSendingService
     * @return
     */
    @RequestMapping("/message")
    @ResponseBody
    @Transactional
    public ReturnModel sendMessage() {
        ReturnModel messModel = new ReturnModel();
        try {
            // Send the message by using userId.
            boolean hasSend = handler.sendMessageToUser(4, new TextMessage("Send a message"));
            System.out.println("Information is ：" + hasSend);

            ReturnModelHelper.StandardResponse(messModel, StatusCode.OK, "Transaction Finish");
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(messModel, e.getClass().getName());
        }
        return messModel;
    }

}
