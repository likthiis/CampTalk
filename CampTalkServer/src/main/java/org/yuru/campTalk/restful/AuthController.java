package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.AuthorizationService;
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
    @RequestMapping(value = "/login", produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel Login(@RequestParam(value = "uid",required = false)String uid,
                             @RequestParam(value = "password",required = false)String password,
                             @RequestParam(value = "token",required = false)String token) {
        System.out.println("Login函数被调用。");
        ReturnModel returnModel = new ReturnModel();
        try {
            if(uid == null && password != null){
                returnModel.setCode("missing_uid");
            }
            if(uid != null && password == null){
                returnModel.setCode("missing_password");
            }
            if(uid == null && password == null&&token == null){
                returnModel.setCode("missing_token");
            }
            if(uid == null && token != null){
                returnModel.setCode("missing_uid");
            }
            if(uid != null && password != null) {
                returnModel = AuthorizationService.Auth1(uid, password);
            }
            if(uid != null && token != null) {
                returnModel = AuthorizationService.Auth2(uid, token);
            }
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(returnModel, e.getClass().getName());
        }
        return returnModel;
    }
}
