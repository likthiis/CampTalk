package com.example.wzf.camptalk;

import android.app.Application;
import android.util.Log;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import de.tavendo.autobahn.WebSocketConnection;
import de.tavendo.autobahn.WebSocketException;
import de.tavendo.autobahn.WebSocketHandler;

public class SocketAppService extends Application {
    // 全局变量招牌：用以确认该类的存在状态
    private String banner = "websocket全局应用";

    private static final String wsurl = "ws://192.168.72.2:16233/websocket";
    private static final String TAG = "SocketAppService";
    private WebSocketConnection mConnect = new WebSocketConnection();
    private String usernameForInitConnect = "test";

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, banner + "开始发挥作用");
    }

    // 将用户名保存在该类内
    public void setEditTextForName(EditText editTextForName) {
        this.usernameForInitConnect = editTextForName.getText().toString();
    }
    // 可以直接显示在textView里面
    public void getBackMessage(TextView textView) {
        String msg = connectPrepare.getReturnMsg();
        textView.setText(msg);
    }


    private void sendUid(String uid) {
        // 这里应该存在将客户端保存的uid设置成user字段的功能，这个字段起到标识符作用。
        // 为了实验，这里将用户名的输入框绑定在user上
        String user = "uid:" + uid;
        if (user != null && user.length() != 0) {
            this.sendMessage(user);
            Log.i(TAG,"将" + user + "发出");
        }
        else {
            // 这里的逻辑是不太必要的，几乎不存在在已经登录的情况下，客户端还不保留uid的情况。
            Toast.makeText(getApplicationContext(), "uid没有保留，或者uid的输入是空的！！！", Toast.LENGTH_SHORT).show();
        }
    }

    // 写一个继承类来使用外部类变量
    // 按照机制，需要将uid传到该类内后再实现连接。并使用getReturnMsg函数来获取从
    // 服务端返回的值
    private class ConnectionClass extends WebSocketHandler {
        private String uid;
        private String returnMsg;

        public ConnectionClass() {

        }

        public void setUid(String uid) {
            this.uid = uid;
        }

        public String getReturnMsg() {
            return returnMsg;
        }

        @Override
        public void onOpen() {
            Log.i(TAG, "在链接类内运行，连接至" + wsurl);
            sendUid(uid);
        }

        // 接受消息的函数
        @Override
        public void onTextMessage(String payload) {
            Log.i(TAG, payload);
            this.returnMsg = payload;
            //mText.setText(payload);
            //mText.setText(payload != null ? payload : "");
        }

        @Override
        public void onClose(int code, String reason) {
            Log.i(TAG, "Connection lost..." + reason);
        }
    }

    // 在外部类设立独立的链接类
    private ConnectionClass connectPrepare = new ConnectionClass();

    public void socketConnect() {
        Log.i(TAG, "ws connect....");
        try {
            connectPrepare.setUid(this.usernameForInitConnect);
            mConnect.connect(wsurl, connectPrepare);
        } catch (WebSocketException e) {
            e.printStackTrace();
        }
    }

    public boolean isConnect() {
        return mConnect.isConnected();
    }

    public void destroy() {
        mConnect.disconnect();
    }

    public void sendMessage(String msg) {
        mConnect.sendTextMessage(msg);
    }
}
