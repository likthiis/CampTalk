package com.example.wzf.camptalk.netService;

import com.example.wzf.camptalk.dto.RequestModel;

public interface IWsCallback<T> {
    void onSuccess(T t);
    void onError(String msg, RequestModel request, Action action);
    void onTimeout(RequestModel request, Action action);
}
