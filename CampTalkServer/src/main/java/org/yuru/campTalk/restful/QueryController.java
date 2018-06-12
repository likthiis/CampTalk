package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.service.query_method.QueryService;

import java.util.ArrayList;
import java.util.List;

/**
 * Author: Likthiis
 * Date  : 2018/6/3
 * Usage : Handle requests for query.
 */

@RestController
@RequestMapping("/query")
public class QueryController {

    @RequestMapping(value = "/query_existence", produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel Query(@RequestParam(value = "uid")String uid) {
        System.out.println("登录前查询是否存在");

        ReturnModel returnModel = new ReturnModel();

        List<String> missingParams = new ArrayList<>();
        if (uid == null) missingParams.add("uid");
        if (missingParams.size() > 0) {
            return ReturnModelHelper.MissingParametersResponse(missingParams);
        }

        try {
            returnModel = QueryService.QueryExistence(uid);
        } catch (Exception ex) {
            ReturnModelHelper.ExceptionResponse(returnModel, ex.getMessage());
        }

        return returnModel;
    }
}
