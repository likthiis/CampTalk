package com.example.wzf.camptalk.netService;

// 用于回调使用websocket服务从服务端接收数据的函数的接口
public interface OnMessageListener {
    void onMessage(String msg);
}
