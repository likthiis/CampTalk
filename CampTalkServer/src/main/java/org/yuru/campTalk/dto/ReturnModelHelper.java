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
     * @param rnModel return model package to be updated
     * @param code status code enum
     * @param retStr execution return data
     */
    public static void StandardResponse(ReturnModel rnModel, StatusCode code, String retStr) {
        rnModel.setCode(code);
        rnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setData(retStr);
        rnModel.setReturnElement(returnElement);
    }

    /**
     * Router exception handler.
     * @param exception exception descriptor
     */
    public static void ExceptionResponse(ReturnModel rnModel, String exception) {
        rnModel.setCode(StatusCode.Exception);
        rnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setMessage(exception);
        rnModel.setReturnElement(returnElement);
    }

    /**
     * Router unauthorized service request handler.
     * @param token unauthorized token
     * @return response package
     */
    public static ReturnModel UnauthorizedResponse(String token) {
        ReturnModel rnModel = new ReturnModel();
        rnModel.setCode(StatusCode.Unauthorized);
        rnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        returnElement.setMessage(token);
        rnModel.setReturnElement(returnElement);
        LogUtil.Log(String.format("Unauthorized service request (token:%s)", token),
                ReturnModelHelper.class.getName(), LogLevelType.UNAUTHORIZED, "");
        return rnModel;
    }

    /**
     * Router request parameter missing handler.
     * @param params missing parameter list
     * @return response package
     */
    public static ReturnModel MissingParametersResponse(List<String> params) {
        ReturnModel rnModel = new ReturnModel();
        rnModel.setCode(StatusCode.Fail);
        rnModel.setTimestamp(TimestampUtil.GetTimestampString());
        ReturnElement returnElement = new ReturnElement();
        StringBuilder sb = new StringBuilder();
        sb.append("miss required parameters:");
        for (String s : params) {
            sb.append(s).append(" ");
        }
        returnElement.setMessage(sb.toString());
        rnModel.setReturnElement(returnElement);
        return rnModel;
    }
}
