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
    /**
     * Warp success response to a ReturnModel
     * @param returnModel return model package to be updated
     * @param code status code enum
     * @param retStr execution return data
     */
    public static void StandardResponse(ReturnModel returnModel, StatusCode code, String retStr) {
        returnModel.setCode(code);
        returnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setData(retStr);
        returnModel.setReturnElement(returnElement);
    }

    /**
     * Router exception handler.
     * @param returnModel return model package to be updated
     * @param exception exception descriptor
     */
    public static void ExceptionResponse(ReturnModel returnModel, String exception) {
        returnModel.setCode(StatusCode.Exception);
        returnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setMessage(exception);
        returnModel.setReturnElement(returnElement);
    }

    /**
     * Router unauthorized service request handler.
     * @param token unauthorized token
     * @return response package
     */
    public static ReturnModel UnauthorizedResponse(String token) {
        ReturnModel returnModel = new ReturnModel();
        returnModel.setCode(StatusCode.Unauthorized);
        returnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setMessage(token);
        returnModel.setReturnElement(returnElement);
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
        returnModel.setCode(StatusCode.Fail);
        returnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        StringBuilder sb = new StringBuilder();
        sb.append("miss required parameters:");
        for (String s : params) {
            sb.append(s).append(" ");
        }
        returnElement.setMessage(sb.toString());
        returnModel.setReturnElement(returnElement);
        return returnModel;
    }
}
