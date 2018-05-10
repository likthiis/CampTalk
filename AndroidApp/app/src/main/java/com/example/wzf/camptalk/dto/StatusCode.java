package com.example.wzf.camptalk.dto;

import java.io.Serializable;

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
