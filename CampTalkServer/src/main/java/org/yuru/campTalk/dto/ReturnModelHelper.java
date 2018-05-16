package org.yuru.campTalk.dto;

import org.yuru.campTalk.utility.LogLevelType;
import org.yuru.campTalk.utility.TimestampUtil;
import org.yuru.campTalk.utility.LogUtil;

import java.util.List;

/**
 * Author: Rinkako
 * Date  : 2018/1/26
 * Usage : Helper methods for ReturnModel construction.
 */
public class ReturnModelHelper {
    public static void StandardResponse(ReturnModel model, String code, String token) {
        model.setCode(code);
        model.setTimestamp(TimestampUtil.GetTimestampString());
        model.setToken(token);
    }

    public static void ExceptionResponse(ReturnModel model, String exception) {
        model.setCode(exception);
        model.setTimestamp(TimestampUtil.GetTimestampString());
    }

    /**
     * Router unauthorized service request handler.
     * @param token unauthorized token
     * @return response package
     */
    public static ReturnModel UnauthorizedResponse(String token) {
        ReturnModel returnModel = new ReturnModel();
        //returnModel.setCode(StatusCode.Unauthorized);
        returnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setMessage(token);
        //returnModel.setReturnElement(returnElement);
        LogUtil.Log(String.format("Unauthorized service request (token:%s)", token),
                ReturnModelHelper.class.getName(), LogLevelType.UNAUTHORIZED, "");
        return returnModel;
    }

    /**
     * Router request parameter missing handler.
     * @param params missing parameter list
     * @return response package
     */
    public static ReturnModel MissingParametersResponse(List<String> params) {
        ReturnModel returnModel = new ReturnModel();
        //returnModel.setCode(StatusCode.Fail);
        returnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        StringBuilder sb = new StringBuilder();
        sb.append("miss required parameters:");
        for (String s : params) {
            sb.append(s).append(" ");
        }
        returnElement.setMessage(sb.toString());
        //returnModel.setReturnElement(returnElement);
        return returnModel;
    }
}
