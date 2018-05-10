package com.example.wzf.camptalk.dto;

public class GetModel {
    private StatusCode code;
    private String timestamp;
    private returnElement returnElement;

    public returnElement getReturnElement() {
        return returnElement;
    }

    public void setReturnElement(returnElement returnElement) {
        this.returnElement = returnElement;
    }

    public StatusCode getCode() {
        return code;
    }

    public void setCode(StatusCode code) {
        this.code = code;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
}
