package com.example.wzf.camptalk;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.example.wzf.camptalk.model.friendRequest;

public class TestTwoActivity extends AppCompatActivity implements View.OnClickListener {

    private SocketAppService socketAppService;
    private static final String TAG = "TestTwoActivity";
    private Button bBackToMain;

    // 好友请求测试按钮(新页面)
    private Button bFriendRequestIn2;

    // 用户查找
    private Button bSendSearch;
    private EditText eInputUid;
    private TextView tShowUser;


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

        bSendSearch = (Button) findViewById(R.id.B_sendSearch);
        bSendSearch.setOnClickListener(this);

        eInputUid = (EditText) findViewById(R.id.E_inputUid);
        tShowUser = (TextView) findViewById(R.id.T_showUser);
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
        if(view == bSendSearch) {
            String uidMsg = "usersearch:" + eInputUid.getText().toString();
            Log.i(TAG, "result is " + uidMsg);
            socketAppService.sendMessage(uidMsg);
            socketAppService.getBackMessage(tShowUser);
//            else {
//                Toast.makeText(TestTwoActivity.this, "没有输入！", Toast.LENGTH_SHORT).show();
//            }
        }
    }
}
