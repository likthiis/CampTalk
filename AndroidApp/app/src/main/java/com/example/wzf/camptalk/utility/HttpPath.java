package com.example.wzf.camptalk.utility;

// 残余代码，留做他用
public class HttpPath {
    private static final String IP = "http://192.168.72.2:16233/";
    public static String getUserLoginPath() {
        return IP + "auth/login";
    }
}
