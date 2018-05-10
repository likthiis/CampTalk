package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.service.ImageSetting;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/setting")
public class SetController {

    @ResponseBody
    @Transactional
    public void Setting(@RequestParam(value = "choose",required = false)String choose,
                               @RequestParam(value = "uid",required = false)String username) {
        ReturnModel returnModel = new ReturnModel();
        try {
            List<String> missingParams = new ArrayList<>();
            if (choose == null) missingParams.add("choose");
            if (username == null) missingParams.add("uid");
            if (missingParams.size() > 0) {
                return;
            }
            if (choose == "1") {
                ImageSetting.ReceivePicture(username);
            }
        } catch (Exception e) {
                ReturnModelHelper.ExceptionResponse(returnModel, e.getClass().getName());
        }
    }
}
