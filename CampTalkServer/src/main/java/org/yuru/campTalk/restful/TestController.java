package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.utility.SerializationUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Handle requests for restful echo testing.
 */

@RestController
@RequestMapping("/api")
//主控台。
public class TestController {

    /**
     * Test echo from engine.
     * @param requiredArg argument required (required)
     * @param notRequiredArg argument not required
     * @return response package
     */
    @RequestMapping(value = "/echo", produces = {"application/json"}) //将http的请求映射到MVC和REST控制器的处理方法上。
    //就是把内容物送给主控台的函数进行处理。
    @ResponseBody
    @Transactional
    public ReturnModel Echo(@RequestParam(value="requiredArg", required = false)String requiredArg,
                            @RequestParam(value="notRequiredArg", required = false)String notRequiredArg) {
        ReturnModel rnModel = new ReturnModel();
        try {
            // miss params
            List<String> missingParams = new ArrayList<>();
            if (requiredArg == null) missingParams.add("requiredArg");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }
            // logic
            String jsonifyResponse = String.format("Welcome to CampTalk Gateway! Echo request: requiredArg(%s), notRequiredArg(%s)", requiredArg, notRequiredArg);
            // return
            ReturnModelHelper.StandardResponse(rnModel, StatusCode.OK, jsonifyResponse);
        } catch (Exception e) {
            ReturnModelHelper.ExceptionResponse(rnModel, e.getClass().getName());
        }
        return rnModel;
    }
}
