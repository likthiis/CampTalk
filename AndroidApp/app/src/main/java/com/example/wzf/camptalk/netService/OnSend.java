package com.example.wzf.camptalk.netService;

// 用于回调使用websocket服务向服务端传输数据的函数的接口
public interface OnSend {
    public void sendMessage(String msg);
}
