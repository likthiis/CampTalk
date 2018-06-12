package com.example.wzf.camptalk.netService;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

public class MessageExchange extends BroadcastReceiver {
    // 从activity传过来的onMessageListener已经完成了函数定义
    private OnMessageListener onMessageListener;
    private Context context;

    public MessageExchange(){

    }

    public MessageExchange(final OnMessageListener onMessageListener, Context context) {
        this.onMessageListener = onMessageListener;
        this.context = context;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if(intent.getAction().equals("com.wsconn.MESSAGEHANDLE")) {
            Bundle bundle = intent.getExtras();
            String returnMsg = bundle.getString("return_msg");

            // 回调
            onMessageListener.onMessage(returnMsg);
        }
    }
}
