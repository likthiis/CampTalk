package org.yuru.campTalk.dto;

import java.io.Serializable;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : The status code used to represent the result of the request.
 */
public enum StatusCode implements Serializable {
    // Request worked right
    OK,
    // Request worked fail
    Fail,
    // Exception exists
    Exception,
    // Token is unauthorized
    Unauthorized
}
