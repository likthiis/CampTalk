package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.RegisterService;

import java.util.ArrayList;
import java.util.List;

/**
 * Author: likthiis
 * Date  : 2018/4/22
 * Usage : Handle register.
 */

@RestController
@RequestMapping("/register")
public class RegisterController {
    /**
     * User can use the uid and password to register.
     * @param uid is set by user,and it is unique(required)
     * @param password is the cleartext one(required)
     * @return response package
     * @see ReturnModel
     */
    @RequestMapping(produces = {"application/json"})
    @Transactional
    public ReturnModel Register(@RequestParam(value="uid")String uid,
                                @RequestParam(value="password")String password){
        ReturnModel returnModel = new ReturnModel();
        try {
            // Handle missing params.
            List<String> missingParams = new ArrayList<>();
            if (uid == null) missingParams.add("uid");
            if (password == null) missingParams.add("password");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            // Register
            String jsonifyResponse = RegisterService.Register(uid, password);
            // Return
            ReturnModelHelper.StandardResponse(returnModel, jsonifyResponse, null);

        }catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(returnModel, e.getClass().getName());
        }
        return returnModel;
    }
}
