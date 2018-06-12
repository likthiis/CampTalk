package com.example.wzf.camptalk.netService;

import com.example.wzf.camptalk.dto.RequestModel;

public class CallbackWrapper {

    private final IWsCallback tempCallback;
    private final Action action;
    private final RequestModel request;


    public CallbackWrapper(IWsCallback tempCallback, Action action, RequestModel request) {
        this.tempCallback = tempCallback;
        this.action = action;
        this.request = request;
    }

    public IWsCallback getTempCallback() {
        return tempCallback;
    }

    public Action getAction() {
        return action;
    }

    public RequestModel getRequest() {
        return request;
    }
}
