package com.example.wzf.camptalk;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;

import com.example.wzf.camptalk.model.friendRequest;

public class TestTwoActivity extends AppCompatActivity implements View.OnClickListener {

    private SocketAppService socketAppService;

    private Button bBackToMain;

    // 好友请求测试按钮(新页面)
    private Button bFriendRequestIn2;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_two_test);
        bindObject();
        socketAppService = (SocketAppService)getApplication();
    }

    private void bindObject() {
        bBackToMain = (Button) findViewById(R.id.B_backToMain);
        bBackToMain.setOnClickListener(this);

        // 将好友请求模块放在第二个页面里
        bFriendRequestIn2 = (Button) findViewById(R.id.B_friendRequestIn2);
        bFriendRequestIn2.setOnClickListener(this);
    }

    private void sendFriendRequest(friendRequest request) {
        String requestMsg = "friendrequest:" + request.getMessageToJson();
        socketAppService.sendMessage(requestMsg);
    }

    @Override
    public void onClick(View view) {
        if(view == bBackToMain) {
            Intent backToMain = new Intent(TestTwoActivity.this, AndroidCampTalk.class);
            startActivity(backToMain);
        }
        if(view == bFriendRequestIn2) {
            friendRequest request = new friendRequest();
            request.setMyUid("admin");
            request.setItsUid("qinne");
            sendFriendRequest(request);
        }
    }
}
