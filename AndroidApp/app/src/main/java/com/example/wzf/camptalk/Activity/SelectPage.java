package com.example.wzf.camptalk.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;

import com.example.wzf.camptalk.R;
import com.example.wzf.camptalk.netService.SocketAppService;

public class SelectPage extends AppCompatActivity implements View.OnClickListener {

    private Button bSingleChat;
    private Button bSearchUser;
    private Button bFriendRequest;
    private Button bBackToLoginPage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu);
        bindObject();
    }

    private void bindObject() {
//        bSingleChat = (Button) findViewById(R.id.B_singleChat);
//        bSearchUser = (Button) findViewById(R.id.B_searchUser);
//        bFriendRequest = (Button) findViewById(R.id.B_friendRequest);
//        bBackToLoginPage = (Button) findViewById(R.id.B_backToLoginPage);
        bSingleChat.setOnClickListener(this);
        bSearchUser.setOnClickListener(this);
        bFriendRequest.setOnClickListener(this);
        bBackToLoginPage.setOnClickListener(this);
    }


    @Override
    public void onClick(View view) {
        if(view == bSingleChat) {
            // 先去好友界面
            Intent nextPage = new Intent(SelectPage.this, ShowFriends.class);
            startActivity(nextPage);
        }
        if(view == bSearchUser) {
            // 进入下一页面
            Intent nextPage = new Intent(SelectPage.this, SearchUser.class);
            startActivity(nextPage);
        }
        if(view == bFriendRequest) {

        }
        if(view == bBackToLoginPage) {
            // 关闭服务
            Intent WSConnect = new Intent(this, SocketAppService.class);
            stopService(WSConnect);
            // 返回上一级页面
            Intent nextPage = new Intent(SelectPage.this, Login.class);
            startActivity(nextPage);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
