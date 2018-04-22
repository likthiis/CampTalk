package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.AuthorizationService;
import org.yuru.campTalk.service.RegisterService;

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
    /**
     * 使用Uid和密码明文获得授权token.
     * @param uid 用户的唯一uid(required)
     * @param password 用户明文密码(required)
     * @return response package
     * @see ReturnModel
     */
    @RequestMapping(value = "/login", produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel Login(@RequestParam(value="uid", required = false)String uid,
                             @RequestParam(value="password", required = false)String password) {
        ReturnModel rnModel = new ReturnModel();
        try {
            // miss params
            List<String> missingParams = new ArrayList<>();
            if (uid == null) missingParams.add("uid");
            if (password == null) missingParams.add("password");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            // logic
            String jsonifyResponse = AuthorizationService.Login(uid, password);
            // return
            ReturnModelHelper.StandardResponse(rnModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(rnModel, e.getClass().getName());
        }
        return rnModel;
    }
}
