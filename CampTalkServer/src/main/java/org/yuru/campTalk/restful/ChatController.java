package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.yuru.campTalk.dto.ReturnModel;
import org.yuru.campTalk.dto.ReturnModelHelper;
import org.yuru.campTalk.dto.StatusCode;
import org.yuru.campTalk.service.AuthorizationService;
import org.yuru.campTalk.service.ChatService;

import java.util.ArrayList;
import java.util.List;

/**
 * 聊天管理器，负责功能：
 * [1]生成会话；
 * [2]发送信息(客户端->服务端)；
 * [3]发送信息(服务端->客户端)；
 *
 */
@RestController
@RequestMapping("/chat")
public class ChatController {

    /**
     * [1]会话生成器。
     * @param target 用户希望联系的朋友uid
     * @param myself 自己的uid
     * @return response package
     * @see ReturnModel
     */
    @RequestMapping(value = "/setRe",produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel RelationSetting(@RequestParam(value = "target", required = false)String target,
                                       @RequestParam(value = "myself", required = false)String myself) {
        ReturnModel rnModel = new ReturnModel();
        try {
            // 参数处理
            List<String> missingParams = new ArrayList<>();
            if (target == null) missingParams.add("target");
            if (myself == null) missingParams.add("myself");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }

            // 会话生成
            String jsonifyResponse = ChatService.RelationSetting(target, myself);

            // 返回
            ReturnModelHelper.StandardResponse(rnModel, StatusCode.OK, jsonifyResponse);

        } catch(Exception e) {
            ReturnModelHelper.ExceptionResponse(rnModel, e.getClass().getName());
        }
        return rnModel;
    }

    /**
     * [2]信息接受器。
     * @param target 用户希望联系的朋友uid
     * @param content 发送的内容
     * @param myself 用户自己的uid
     * @return response package
     * @see ReturnModel
     */
    @RequestMapping(value = "/getmessage",produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel MessageGetting(@RequestParam(value = "target", required = false)String target,
                                      @RequestParam(value = "content", required = false)String content,
                                      @RequestParam(value = "myself", required = false)String myself) {
        ReturnModel rnModel = new ReturnModel();
        try {
            // 参数处理
            List<String> missingParams = new ArrayList<>();
            if (target == null) missingParams.add("target");
            if (content == null) missingParams.add("content");
            if (myself == null) missingParams.add("myself");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }

            // 会话生成
            String jsonifyResponse = ChatService.MessageGetting(target, content, myself);

            // 返回
            ReturnModelHelper.StandardResponse(rnModel, StatusCode.OK, jsonifyResponse);

        } catch(Exception e) {
            ReturnModelHelper.ExceptionResponse(rnModel, e.getClass().getName());
        }
        return rnModel;
    }

    /**
     * [3]信息代传器。
     * @param target 用户希望联系的朋友uid
     * @param content 发送的内容
     * @return response package
     * @see ReturnModel
     */

    //TODO:发出的数据格式的注解
    @RequestBody
    @Transactional
    public void MessageSend(@RequestParam(value = "target", required = false)String target,
                            @RequestParam(value = "content", required = false)String content) {
        //TODO:客户端发出的控制逻辑
    }

}
