package com.example.wzf.camptalk.Activity;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.example.wzf.camptalk.R;
import com.example.wzf.camptalk.dto.RequestModel;
import com.example.wzf.camptalk.dto.ReturnModel;
import com.example.wzf.camptalk.netService.MessageExchange;
import com.example.wzf.camptalk.netService.OnMessageListener;
import com.example.wzf.camptalk.netService.OnSend;
import com.example.wzf.camptalk.netService.SocketAppService;
import com.google.gson.Gson;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;

public class ShowFriends extends AppCompatActivity implements View.OnClickListener,OnMessageListener {
    private TextView tShowFriends;
    private EditText eInputFriendUid;
    private Button bChatGo;
    private OnSend onSendBinder;
    private BindService bindService;
    private BroadcastReceiver mBroadcastReceiver;

    private class BindService implements ServiceConnection {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            onSendBinder = (OnSend)service;
            // 展示好友
            showFriends();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list_friends);
        bindObject();
        // 动态注册广播
        mBroadcastReceiver = new MessageExchange(this,this);
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.wsconn.MESSAGEHANDLE");
        registerReceiver(mBroadcastReceiver, intentFilter);


        // 设置websocket连接服务的监听器
        Intent intent = new Intent(this, SocketAppService.class);
        bindService = new BindService();
        bindService(intent, bindService, BIND_AUTO_CREATE);

    }

    private void showFriends() {

        // 请注意：token在安卓服务区提供，活动界面无需干涉
        RequestModel requestModel = new RequestModel.Builder<>()
                .action("showmyfriends")
                .timestamp(new Timestamp(new Date().getTime()).toString())
                .token("stand_by")
                .req("stand_by") // 发送自己的uid让服务端提取好友数据
                .build();

        onSendBinder.sendMessage(new Gson().toJson(requestModel));
    }

    private void bindObject() {
        tShowFriends = findViewById(R.id.T_showFriends);
        eInputFriendUid = findViewById(R.id.E_inputSearchUid);
        bChatGo = findViewById(R.id.B_chatGo);
        bChatGo.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        if(view == bChatGo) {

        }
    }

    private String token;
    private String uid;

    @Override
    public void onMessage(String msg) {
        ReturnModel returnModel = new Gson().fromJson(msg, ReturnModel.class);
        if(returnModel.getStatus().equals("friends_null")) {
            tShowFriends.setText("无好友");
            return;
        }
        if(returnModel.getStatus().equals("get_fail")) {
            tShowFriends.setText("查询出现错误");
            return;
        }
        if(returnModel.getStatus().equals("get_success")) {
            ArrayList<String> friends = (ArrayList) returnModel.getRequest();
            String result = "你的好友：\n";
            for(String o : friends) {
                result += o + "\n";
            }
            tShowFriends.setText(result);
        }
    }

//    @Override
//    public void getToken(String token) {
//        this.token = token;
//        return;
//    }
//
//    @Override
//    public void getUid(String uid) {
//        this.uid = uid;
//        return;
//    }

    @Override
    protected void onDestroy() {
        unbindService(bindService);
        unregisterReceiver(mBroadcastReceiver);
        super.onDestroy();
    }
}
