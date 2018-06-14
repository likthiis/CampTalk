package com.example.wzf.camptalk.netService;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import com.example.wzf.camptalk.dto.RequestModel;
import com.google.gson.Gson;
import org.java_websocket.client.WebSocketClient;

import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;

import org.java_websocket.drafts.Draft_6455;
import org.java_websocket.handshake.ServerHandshake;

public class SocketAppService extends Service {

    private String wsurl;
    private static final String TAG = "SocketAppService";
    private static WebSocketClient mClient;
    private Draft_6455 mDraft_17 = new Draft_6455();
    public static final String MESSAGEBACK = "com.wsconn.MESSAGEHANDLE";
    // handler模式的标识
    private final int SUCCESS_HANDLE = 0x01;
    private final int ERROR_HANDLE = 0x02;
    // 客户端内部的状态码
    private WsStatus myStatus;

    // 服务启动后将服务端token保存在这里
    private String token;


    public SocketAppService() {
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "onCreate() executed");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.i(TAG, "onStartCommand() executed");
        Bundle bundle = intent.getExtras();
        String token = bundle.getString("token");
        Log.i(TAG, "口令是：" + token);
        String uid = bundle.getString("uid");
        Log.i(TAG, "uid是：" + uid);
        this.token = token;
        this.wsurl = HttpPath.getWebSocketPath(uid);
        startThreadOfWebSocket();
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        // 关闭连接并处理掉这个类
        mClient.close();
        super.onDestroy();
        Log.i(TAG, "onDestroy() executed");
    }


    // 使用绑定函数建立监听器
    @Override
    public IBinder onBind(Intent intent) {
        return new MyBinder(this.token);
    }

    // 继承绑定类的拓展类
    private class MyBinder extends Binder implements OnSend {
        private String token;

        public MyBinder(String token) {
            this.token = token;
        }

        @Override
        public void sendMessage(String msg) {
            RequestModel requestModel = new Gson().fromJson(msg, RequestModel.class);
            requestModel.setToken(this.token);
            String finalMsg = new Gson().toJson(requestModel);
            mClient.send(finalMsg);
        }
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.i("SocketAppService", "onUnbind");
        return super.onUnbind(intent);
    }

    // 通过广播向中介广播类发送由服务端返回的数据
    public void sendByBroadCast(Bundle bundle, String action) {
        Intent intent = new Intent();
        intent.putExtras(bundle);
        intent.setAction(action);
        Log.i(TAG, "bundle message back");
        sendBroadcast(intent);
    }

    private Handler mHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SUCCESS_HANDLE:
                    CallbackDataWrapper successWrapper = (CallbackDataWrapper) msg.obj;
                    successWrapper.getCallback().onSuccess(successWrapper.getData());
                    break;
                case ERROR_HANDLE:
                    CallbackDataWrapper errorWrapper = (CallbackDataWrapper) msg.obj;
                    errorWrapper.getCallback().onFail((String) errorWrapper.getData());
                    break;
            }
        }
    };



    // 启动webcosket线程
    public void startThreadOfWebSocket() {
        WebSocketConn webSocketConn = new WebSocketConn();
        Thread connectThread = new Thread(webSocketConn, "长链接线程");
        connectThread.start();
    }

    // 初始化webcosket链接类
    class WebSocketConn implements Runnable {
        @Override
        public void run() {
            try {
                mClient = new WebSocketClient(new URI(wsurl), mDraft_17,
                        null,3000) {

                    @Override
                    public void onOpen(ServerHandshake handshakedata) {
                        Log.i(TAG, "连接成功");
                    }

                    @Override
                    public void onMessage(String message) {
                        // 处理token
                        if(message.equals("invaild_token")) {
                            Log.i(TAG, "token出现问题");
                            // 临时
                            return;
                        }
                        if(message.equals("token_check_sql_wrong")) {
                            Log.i(TAG, "token查询出现问题");
                            // 临时
                            return;
                        }
                        if(message.equals("token_check_rollback_wrong")) {
                            Log.i(TAG, "token查询出现问题");
                            // 临时
                            return;
                        }
                        if(message.equals("token_check_overdue")) {
                            Log.i(TAG, "token过期");
                            // 临时
                            return;
                        }
                        Log.i(TAG, "获得信息为: " + message);
                        Bundle bundle = new Bundle();
                        bundle.putString("return_msg", message);
                        sendByBroadCast(bundle, MESSAGEBACK);
                    }

                    @Override
                    public void onError(Exception ex) {
                        Log.i(TAG, "发生意外: " + ex);
                    }

                    @Override
                    public void onClose(int code, String reason, boolean remote) {
                        Log.i(TAG, "长链接关闭");
                    }
                };
                Log.i(TAG, "客户端建立连接connect()");
                mClient.connect();
            } catch (URISyntaxException e) {
                Log.i(TAG, "URISyntaxException: " + e.getMessage());
                e.printStackTrace();
            } catch (Exception e) {
                Log.i(TAG, "未知错误: ");
                e.printStackTrace();
            }
        }
    }

//    class WebSocketConn implements Runnable {
//
//        @Override
//        public void run() {
//            Log.d(TAG, "测试线程");
//        }
//
//    }

    // 对外接口
    public <T> void activitySend(T req, Action action, final ICallback callback) {
        sendReq(req, action, callback);
    }


    @SuppressWarnings("unchecked")
    private <T> void sendReq(T req, Action action, final ICallback callback) {
        RequestModel request = new RequestModel.Builder<T>()
                .action(action.getAction())
                .timestamp(new Timestamp(System.currentTimeMillis()).toString())
                .token("111")
                .req(req)
                .build();

        IWsCallback temp = new IWsCallback() {
            @Override
            public void onSuccess(Object o) {
                mHandler.obtainMessage(SUCCESS_HANDLE, new CallbackDataWrapper(callback, o))
                        .sendToTarget();
            }

            @Override
            public void onError(String msg, RequestModel request, Action action) {
                mHandler.obtainMessage(ERROR_HANDLE, new CallbackDataWrapper(callback, msg))
                        .sendToTarget();
            }

            @Override
            public void onTimeout(RequestModel request, Action action) {
                Log.i(TAG, "超时了");
            }
        };

        Log.i(TAG, "send text: " +  new Gson().toJson(request));

        mClient.send(new Gson().toJson(request));
    }

    private void doAuth() {
        sendReq(null, Action.LOGIN, new ICallback() {
            @Override
            public void onSuccess(Object o) {
                Log.i(TAG, "授权成功");
                setStatus(WsStatus.AUTH_SUCCESS);
            }

            @Override
            public void onFail(String msg) {
                Log.i(TAG, "授权失败");
            }
        });
    }

    public WsStatus getMyStatus() {
        return myStatus;
    }

    public void setStatus(WsStatus myStatus) {
        this.myStatus = myStatus;
    }
}
