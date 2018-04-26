package org.yuru.campTalk.restful;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.AuthorizationService;
import org.yuru.campTalk.websocket.MyWebSocketHandler;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

/**
 * Author: Rinkako
 * Date  : 2018/4/21
 * Usage : Handle requests for authorization.
 */
@RestController
@RequestMapping("/auth")
public class AuthController {
    @Autowired
    MyWebSocketHandler handler;
    /**
     * Using uid and cleartext password to get the token.
     * At the same time,a connection using websocket will be built up.
     * @return response package
     * @see ReturnModel
     */
    @RequestMapping(value = "/login", produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel Login(HttpSession webSocketSession) {
        String uid = (String)webSocketSession.getAttribute("uid");
        String password = (String)webSocketSession.getAttribute("password");
        ReturnModel returnModel = new ReturnModel();
        try {
            // Find missing params.
            List<String> missingParams = new ArrayList<>();
            if (uid == null) {
                missingParams.add("uid");
            }
            if (password == null) {
                missingParams.add("password");
            }
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            // logic
            String jsonifyResponse = AuthorizationService.Login(webSocketSession, uid, password);
            // return
            ReturnModelHelper.StandardResponse(returnModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(returnModel, e.getClass().getName());
        }
        return returnModel;
    }
}
