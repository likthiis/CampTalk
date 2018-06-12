package com.example.wzf.camptalk.netService;

// ui回调

public interface ICallback<T> {
    void onSuccess(T t);
    void onFail(String msg);
}
