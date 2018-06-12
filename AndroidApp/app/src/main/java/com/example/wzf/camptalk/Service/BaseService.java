package com.example.wzf.camptalk.Service;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

// 安卓服务示范类，因为是标准，所以虽然没有什么用但还是保留下来以供参考
public class BaseService extends Service {
    private WebsocketBinder mBinder = new WebsocketBinder();

    public BaseService() {

    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.i("BaseService", "onBind");
        return mBinder;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.i("BaseService", "onUnbind");
        return super.onUnbind(intent);
    }

    public class WebsocketBinder extends Binder {
        public void itsFunction() { // from implements OnMessage
            Log.i("WebsocketBinder", "内部类运行");
        }

        public void testFunction() { // from implements OnMessage
            Log.i("WebsocketBinder", "内部类运行接口函数");
        }
    }

    public void testFunction() { // from implements OnMessage

    }
}
