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
 * A controller to manage chats between users.
 */
@RestController
@RequestMapping("/chat")
public class ChatController {

    /**
     * While a user want to chat with one of its friends,the system will help it
     * generate a database entry.
     * @param target represents the man that is the friend user wants to chat with(required)
     * @param myself represents the user(required)
     * @return response package
     * @see ReturnModel
     */
    @RequestMapping(value = "/setRe",produces = {"application/json"})
    @ResponseBody
    @Transactional
    public ReturnModel RelationSetting(@RequestParam(value = "target")String target,
                                       @RequestParam(value = "myself")String myself) {
        ReturnModel rnModel = new ReturnModel();
        try {
            // handle missing params
            List<String> missingParams = new ArrayList<>();
            if (target == null) missingParams.add("target");
            if (myself == null) missingParams.add("myself");
            if (missingParams.size() > 0) {
                return ReturnModelHelper.MissingParametersResponse(missingParams);
            }

            // generate the session
            String jsonifyResponse = ChatService.RelationSetting(target, myself);

            // return
            ReturnModelHelper.StandardResponse(rnModel, jsonifyResponse, null);

        } catch(Exception e) {
            ReturnModelHelper.ExceptionResponse(rnModel, e.getClass().getName());
        }
        return rnModel;
    }

    /**
     *
     * @param target
     * @param content
     * @param myself
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
            ReturnModelHelper.StandardResponse(rnModel, jsonifyResponse, null);

        } catch(Exception e) {
            ReturnModelHelper.ExceptionResponse(rnModel, e.getClass().getName());
        }
        return rnModel;
    }

    /**
     *
     * @param target
     * @param content
     * @return response package
     * @see ReturnModel
     */

    @Transactional
    public void MessageSend(@RequestParam(value = "target", required = false)String target,
                            @RequestParam(value = "content", required = false)String content) {
        //TODO:客户端发出的控制逻辑
    }

}
