package com.example.wzf.camptalk;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.example.wzf.camptalk.model.message;


public class AndroidCampTalk extends AppCompatActivity implements View.OnClickListener {

    private SocketAppService socketAppService;
    private static final String TAG = "AndroidCampTalk";
    private EditText mContent;
    private Button mSend;
    private TextView mText;
    private EditText mUserName;
    private EditText mToSb;
    private Button bAct;
    private Button bJumpTo2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_android_camp_talk);
        bindObject();
        socketAppService = (SocketAppService)getApplication();
    }

    private void bindObject() {
        mContent = (EditText) findViewById(R.id.E_msg);
        mUserName = (EditText) findViewById(R.id.E_username);
        mToSb = (EditText) findViewById(R.id.E_tosb);
        mSend = (Button) findViewById(R.id.B_send);
        mText = (TextView) findViewById(R.id.T_msg);
        bAct = (Button) findViewById(R.id.B_act);
        bJumpTo2 = (Button) findViewById(R.id.B_jumpTo2);
        mSend.setOnClickListener(this);
        bAct.setOnClickListener(this);
        bJumpTo2.setOnClickListener(this);
    }

    private void sendMessage(String sender,String receiver,String msg) {
        // 将消息放进类里面处理，并转化为JSON格式发出
        if(socketAppService.isConnect()) {
            message msgModel = new message();// 默认单聊
            msgModel.setSender(sender);
            msgModel.setReceiver(receiver);
            msgModel.setContent(msg);
            String comMsg = "singlechat:" + msgModel.getMessageToJson();
            socketAppService.sendMessage(comMsg);
        } else {
            Log.i(TAG, "no connection!!");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //mConnect.disconnect();
    }

    @Override
    public void onClick(View view) {
        if(view == bAct) {
            socketAppService.setEditTextForName(mUserName);
            socketAppService.socketConnect();
            socketAppService.getBackMessage(mText);
        }
        if(view == mSend) {
            // 如果是发送键，就执行以下代码
            Log.i(TAG, "发送信息......");
            String sender = mUserName.getText().toString();
            String receiver = mToSb.getText().toString();
            String msg = mContent.getText().toString();

            sendMessage(sender, receiver, msg);
        }
//        if(view == bFriendRequest) {
//            // 测试好友请求
//
//        }
        if(view == bJumpTo2) {
            Intent testTwoActivity = new Intent(AndroidCampTalk.this, TestTwoActivity.class);
            startActivity(testTwoActivity);
        }
    }
}
