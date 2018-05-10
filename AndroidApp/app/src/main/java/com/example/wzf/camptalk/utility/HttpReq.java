package com.example.wzf.camptalk.utility;

import com.example.wzf.camptalk.dto.GetModel;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

public class HttpReq {
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

    public static GetModel toPostdata(List<BasicNameValuePair> parameters) throws IOException {
        HttpClient client=new DefaultHttpClient();
        HttpPost postBag=new HttpPost(HttpPath.getUserLoginPath());
        UrlEncodedFormEntity params=new UrlEncodedFormEntity(parameters,"UTF-8");
        postBag.setEntity(params);

        HttpResponse response= client.execute(postBag);
        GetModel getModel = null;
        if(response.getStatusLine().getStatusCode()==200){
            String str;
            HttpEntity entity=response.getEntity();
            str = EntityUtils.toString(entity, "UTF-8");
            System.out.println(str);
            getModel = JsonUtil.getJsonToModel(str);
        }
        return getModel;
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
