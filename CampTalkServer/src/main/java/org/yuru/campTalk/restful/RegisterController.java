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
     * 进行注册，暂时只需要输入密码和昵称就可以了。
     * @param uid 用户自定义不可重复名(required)
     *
     * 特别提醒：本设计如若后期修改，则需要对服务端和客户端一定规模的更新。
     *
     * @param password 用户明文密码(required)
     * @return response package
     * @see ReturnModel
     */

    @RequestMapping(produces = {"application/json"})
    @Transactional
    public ReturnModel Register(@RequestParam(value="uid", required = false)String uid,
                                @RequestParam(value="password", required = false)String password){
        ReturnModel usModel = new ReturnModel();
        try {
            //缺失参数。
            List<String> missingParams = new ArrayList<>();
            if (uid == null) missingParams.add("uid");
            if (password == null) missingParams.add("password");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            // 注册
            String jsonifyResponse = RegisterService.Register(uid, password);
            // 返回
            ReturnModelHelper.StandardResponse(usModel, StatusCode.OK, jsonifyResponse);

        }catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(usModel, e.getClass().getName());
        }
        return usModel;
    }
}
