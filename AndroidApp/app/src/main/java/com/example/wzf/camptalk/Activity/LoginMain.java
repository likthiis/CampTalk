package com.example.wzf.camptalk.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.example.wzf.camptalk.R;
import com.example.wzf.camptalk.dto.ReturnModel;
import com.example.wzf.camptalk.netService.HttpUtil;
import com.example.wzf.camptalk.netService.MessageExchange;
import com.example.wzf.camptalk.netService.SocketAppService;
import com.google.gson.Gson;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import java.io.IOException;
import java.nio.BufferUnderflowException;
import java.util.ArrayList;
import java.util.List;

public class LoginMain extends AppCompatActivity implements View.OnClickListener {

    private static LoginMain instance;
    private Button bLogin;
    private EditText eLoginPassword;
    private EditText eLoginName;

    private static final String TAG = "LoginMain";

    public static LoginMain getInstance() {
        return instance;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        bindObject();
    }

    private void bindObject() {
        bLogin = (Button) findViewById(R.id.B_login);
        eLoginName = (EditText) findViewById(R.id.E_loginName);
        eLoginPassword = (EditText) findViewById(R.id.E_loginPassword);
        bLogin.setOnClickListener(this);
    }

    private boolean judgeEmpty() {
        if(TextUtils.isEmpty(eLoginName.getText()) || TextUtils.isEmpty(eLoginPassword.getText())) {
            Toast.makeText(getApplicationContext(), "用户名或密码不能为空", Toast.LENGTH_SHORT).show();
            return false;
        }
        return true;
    }

    private void testLogin() {
        if(eLoginName.getText().toString().equals("test") && eLoginPassword.getText().toString().equals("test")) {
            //startWebsocket();
            // 进入下一页面
            Intent nextPage = new Intent(LoginMain.this, SelectPage.class);
            startActivity(nextPage);
        }
    }

    // 使用handler模式
    Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            Bundle data = msg.getData();
            String val = data.getString("result");
            String userId = data.getString("uid");
            Log.i(TAG,"请求结果:" + val);
            login(val, userId);
        }
    };

    // 开一个子线程发送https请求
    Runnable runnable = new Runnable() {
        @Override
        public void run() {
            String uid = eLoginName.getText().toString();
            String password = eLoginPassword.getText().toString();
            String returnModelJSON = "没有数据";
            ArrayList<NameValuePair> data = new ArrayList<NameValuePair>();
            data.add(new BasicNameValuePair("uid", uid));
            data.add(new BasicNameValuePair("password", password));
            try {
                returnModelJSON = HttpUtil.loginPOST(data);

                Message msg = new Message();
                Bundle bundle = new Bundle();
                bundle.putString("result", returnModelJSON);
                bundle.putString("uid", uid);
                msg.setData(bundle);
                handler.sendMessage(msg);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    };

    private void login(String returnModelJSON, String userId) {
        if(!returnModelJSON.equals("没有数据")) {
            Gson gson = new Gson();
            ReturnModel returnModel = gson.fromJson(returnModelJSON, ReturnModel.class);
            if(returnModel.getStatus().equals("auth_success")) {
                Toast.makeText(getApplicationContext(), "登录成功", Toast.LENGTH_SHORT).show();

                // 启动ws线程
                startWebsocket(returnModel.getToken(), userId);

                // 进入下一页面
                Intent nextPage = new Intent(LoginMain.this, SelectPage.class);
                startActivity(nextPage);
            } else {
                handlerError(returnModel.getStatus());
            }
        } else {
            Toast.makeText(getApplicationContext(), "登录出现问题", Toast.LENGTH_SHORT).show();
        }
    }

    private void handlerError(String status) {
        if(status.equals("user_not_valid")) {
            Toast.makeText(getApplicationContext(), "用户不存在，请检查用户输入", Toast.LENGTH_SHORT).show();
        }
        if(status.equals("blocked_account")) {
            Toast.makeText(getApplicationContext(), "账号已封禁", Toast.LENGTH_SHORT).show();
        }
        if(status.equals("password_invalid")) {
            Toast.makeText(getApplicationContext(), "密码错误", Toast.LENGTH_SHORT).show();
        }
    }

    public void startWebsocket(String token,String userId) {
        // 开始长链接线程(websocket连接类以线程形式保持)
        Intent startWSConnect = new Intent(this, SocketAppService.class);
        Bundle bundle = new Bundle();
        bundle.putString("token", token);
        bundle.putString("uid", userId);
        startWSConnect.putExtras(bundle);
        startService(startWSConnect);
    }

    @Override
    public void onClick(View view) {
        if(view == bLogin) {
            boolean isLegal = judgeEmpty();
            if(!isLegal) {
                return;
            }

            // 测试与正式两个函数
            //testLogin();

            // 使用线程与handler模式处理http
            new Thread(runnable).start();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
