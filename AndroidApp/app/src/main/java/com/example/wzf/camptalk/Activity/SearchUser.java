package com.example.wzf.camptalk.Activity;

import android.app.VoiceInteractor;
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
import android.widget.Toast;

import com.example.wzf.camptalk.R;
import com.example.wzf.camptalk.dto.RequestModel;
import com.example.wzf.camptalk.dto.ReturnModel;
import com.example.wzf.camptalk.model.ShowSearchUser;
import com.example.wzf.camptalk.netService.MessageExchange;
import com.example.wzf.camptalk.netService.OnMessageListener;
import com.example.wzf.camptalk.netService.OnSend;
import com.example.wzf.camptalk.netService.SocketAppService;
import com.google.gson.Gson;

import java.sql.Timestamp;
import java.util.Date;

public class SearchUser extends AppCompatActivity implements View.OnClickListener,OnMessageListener {

    private TextView tSearchUser;
    private EditText eInputSearchUid;
    private Button bSubmit;
    private TextView tShowUser;
    private OnSend onSendBinder;
    private WatchService watchService;
    private BroadcastReceiver mBroadcastReceiver;

    private class WatchService implements ServiceConnection {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            onSendBinder = (OnSend)service;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_search);
        bindObject();

        // 动态注册广播
        mBroadcastReceiver = new MessageExchange(this,this);
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.wsconn.MESSAGEHANDLE");
        registerReceiver(mBroadcastReceiver, intentFilter);

        // 设置websocket连接服务的监听器
        Intent intent = new Intent(this, SocketAppService.class);
        watchService = new WatchService();
        bindService(intent, watchService, BIND_AUTO_CREATE);
    }

    private void bindObject() {
        tSearchUser = (TextView) findViewById(R.id.T_searchUser);
        eInputSearchUid = (EditText) findViewById(R.id.E_inputSearchUid);
        bSubmit = (Button) findViewById(R.id.B_submit);
        tShowUser = (TextView) findViewById(R.id.T_showUser);
        bSubmit.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        if(view == bSubmit) {
            if(eInputSearchUid.getText().toString().equals("")) {
                Toast.makeText(getApplicationContext(), "该字段不能为空", Toast.LENGTH_SHORT).show();
            }
            else {
                String uid = eInputSearchUid.getText().toString();

                RequestModel requestModel = new RequestModel.Builder<>()
                        .action("usersearch")
                        .timestamp(new Timestamp(new Date().getTime()).toString())
                        .token("还没有写请注意")
                        .req(uid)
                        .build();

                onSendBinder.sendMessage(new Gson().toJson(requestModel));
            }
        }
    }

    @Override
    public void onMessage(String msg) {
        // 返回一个结构体
        ReturnModel returnModel = new Gson().fromJson(msg, ReturnModel.class);
        if(returnModel.getStatus().equals("can_not_find")) {
            tShowUser.setText("查找不到此用户");
        } else if(returnModel.getStatus().equals("success_query")) {
            String request = new Gson().toJson(returnModel.getRequest());
            ShowSearchUser showSearchUser = new Gson().fromJson(request, ShowSearchUser.class);
//            ShowSearchUser showSearchUser = new Gson().fromJson(returnModel.getRequest(), ShowSearchUser.class);
            String showText = String.format("用户名称：%s，用户等级：%s，用户地点：%s", showSearchUser.getUsername(),
                    showSearchUser.getLevel(), showSearchUser.getLocation());
            tShowUser.setText(showText);
        } else {
            tShowUser.setText("查询出现错误");
        }
    }

    @Override
    protected void onDestroy() {
        unbindService(watchService);
        unregisterReceiver(mBroadcastReceiver);
        super.onDestroy();
    }
}
