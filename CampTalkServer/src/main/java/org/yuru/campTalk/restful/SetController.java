package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.ImageService;
import org.yuru.campTalk.service.NicknameService;
import org.yuru.campTalk.service.PasswordService;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/setting")
public class SetController {

    @ResponseBody
    @Transactional
    @RequestMapping("/picset")
    public ReturnModel PictureSetting(@RequestParam(value = "extension",required = false)String extension,
                                      @RequestParam(value = "uid",required = false)String username) {
        ReturnModel returnModel = new ReturnModel();
        try {
            List<String> missingParams = new ArrayList<>();
            if (extension == null) missingParams.add("extension");
            if (username == null) missingParams.add("uid");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            String jsonifyResponse = ImageService.ReceivePicture(username, extension);
            ReturnModelHelper.StandardResponse(returnModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnModel;
    }

    @ResponseBody
    @Transactional
    @RequestMapping("/password")
    public ReturnModel PasswordSetting(@RequestParam(value = "uid",required = false)String username,
                                       @RequestParam(value = "oldpwd",required = false)String oldPassword,
                                       @RequestParam(value = "newpwd",required = false)String newPassword) {
        ReturnModel returnModel = new ReturnModel();
        try {
            List<String> missingParams = new ArrayList<>();
            if (username == null) missingParams.add("uid");
            if (oldPassword == null) missingParams.add("oldpwd");
            if (newPassword == null) missingParams.add("newpwd");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            String jsonifyResponse = PasswordService.ChangePassword(username, oldPassword, newPassword);
            ReturnModelHelper.StandardResponse(returnModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(returnModel, e.getClass().getName());
        }
        return returnModel;
    }

    @ResponseBody
    @Transactional
    @RequestMapping("/nickname")
    public ReturnModel PasswordSetting(@RequestParam(value = "uid",required = false)String username,
                                       @RequestParam(value = "nickname",required = false)String nickname) {
        ReturnModel returnModel = new ReturnModel();
        try {
            List<String> missingParams = new ArrayList<>();
            if (username == null) missingParams.add("uid");
            if (nickname == null) missingParams.add("nickname");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            String jsonifyResponse = NicknameService.ChangeNickname(username,nickname);
            ReturnModelHelper.StandardResponse(returnModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(returnModel, e.getClass().getName());
        }
        return returnModel;
    }
}
