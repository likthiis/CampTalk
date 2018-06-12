package com.example.wzf.camptalk.netService;

public class HttpPath {
    // http路径设施类
    private static final String IP = "http://192.168.72.2:16233/";

    public static String getUserLoginPath() {
        return IP + "auth/login";
    }

    public static String getWebSocketPath(String userId) {
        return IP + "/websocket/" + userId;
    }
}
