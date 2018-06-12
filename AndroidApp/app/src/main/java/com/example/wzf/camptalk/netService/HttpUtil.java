package com.example.wzf.camptalk.netService;


import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;


public class HttpUtil {
    // GETPOST设施类
    public static String TAG = "HTTP设施类";

    public static String getData() throws Exception {
        try {
            URL url=new URL(HttpPath.getUserLoginPath());
            HttpURLConnection conn=(HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(5000);
            conn.setRequestMethod("GET");

            if(conn.getResponseCode()==200){
                InputStream ips=conn.getInputStream();
                byte[] data=read(ips);
                String str=new String(data);
                System.out.println(str);
                return str;
            }else{
                return "网络错误 ：conn.getResponseCode() ="+conn.getResponseCode();
            }
        } catch(MalformedURLException e) {
            return "HttpService.getGamesData()发生异常！ "+e.getMessage();
        }
    }

    public static byte[] read(InputStream inStream) throws Exception {
        ByteArrayOutputStream outStream=new ByteArrayOutputStream();
        byte[] buffer=new byte[1024];
        int len=0;
        while((len=inStream.read(buffer))!=-1){
            outStream.write(buffer,0,len);
        }
        inStream.close();
        return outStream.toByteArray();
    }

    // 使用POST方法递交login所需的数据
    public static String loginPOST(ArrayList<NameValuePair> data) throws ClientProtocolException, IOException {
        String path = HttpPath.getUserLoginPath();
        HttpPost httpPost = new HttpPost(path);
        // 传递变量用NameValuePair[]数据存储，通过httpRequest.setEntity()方法来发出HTTP请求
        List<NameValuePair> list = data;
        httpPost.setEntity(new UrlEncodedFormEntity(list, HTTP.UTF_8));

        // 取得HTTP response
        HttpResponse response = new DefaultHttpClient().execute(httpPost);
        // 若状态码为200
        if(response.getStatusLine().getStatusCode() == 200){
            // 取出应答字符串
            HttpEntity entity = response.getEntity();
            String result = EntityUtils.toString(entity, HTTP.UTF_8);
            return result;
        }
        return "POST ERROR!";
    }

    public static String toGetData(){
        String str="获取数据失败";
        HttpClient client=new DefaultHttpClient();
        HttpGet getBag=new HttpGet(HttpPath.getUserLoginPath());
        try {
            HttpResponse httpResponse=client.execute(getBag);

            if(httpResponse.getStatusLine().getStatusCode()==200){
                str=EntityUtils.toString(httpResponse.getEntity(),"UTF-8");
            }
            return str;
        } catch (ClientProtocolException e) {
            return "toGetData 异常："+e.getMessage();
        } catch (IOException e) {
            return "toGetData 异常："+e.getMessage();
        }
    }
}
