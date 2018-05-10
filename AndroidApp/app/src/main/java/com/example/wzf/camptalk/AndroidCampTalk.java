package com.example.wzf.camptalk;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.example.wzf.camptalk.dto.GetModel;
import com.example.wzf.camptalk.utility.HttpReq;

import org.apache.http.message.BasicNameValuePair;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import butterknife.Bind;
import butterknife.ButterKnife;

public class AndroidCampTalk extends AppCompatActivity {

    @Bind(R.id.banner)
    TextView ctBanner;
    @Bind(R.id.username)
    EditText ctUsername;
    @Bind(R.id.password)
    EditText ctPassword;
    @Bind(R.id.loginCommit)
    Button ctLoginCommit;

    private Thread thread;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_android_camp_talk);
        ButterKnife.bind(this);

        ctLoginCommit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                thread = new Thread(new loginRunnable());
                thread.start();
            }
        });
    }

    Handler handler = new Handler() {
      public void handleMessage(android.os.Message msg) {
          GetModel model = (GetModel) msg.obj;
          if(model.getReturnElement().getData().toString().equals("#login_success")) {
              Toast.makeText(AndroidCampTalk.this, "登录成功！", Toast.LENGTH_SHORT).show();
              Intent intent = new Intent();
              intent.setClass(AndroidCampTalk.this, ChatPageActivity.class);
              startActivity(intent);
          }
          else {
              new AlertDialog.Builder(AndroidCampTalk.this)
                      .setTitle("CampTalk")
                      .setMessage("登录失败，请重新尝试！")
                      .setPositiveButton("确定", null)
                      .show();
          }
      };
    };

    class loginRunnable implements Runnable {
        @Override
        public void run() {
            String username = ctUsername.getText().toString();
            String password = ctPassword.getText().toString();

            List<BasicNameValuePair> list = new ArrayList<BasicNameValuePair>();
            list.add(new BasicNameValuePair("uid",username));
            list.add(new BasicNameValuePair("password",password));
            try {
                GetModel getModel = HttpReq.toPostdata(list);
                if(getModel == null) {
                    System.out.println("信息接收出现问题，停止服务");
                    return;
                }
                Message message = handler.obtainMessage();
                message.obj = getModel;
                handler.sendMessage(message);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
