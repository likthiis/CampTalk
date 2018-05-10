package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.HibernateUtil;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class ImageSetting {
    public static void DefaultPicture() {

    }
    public static void ReceivePicture(String username) {
        boolean judge = true;
        Session DBsession = HibernateUtil.GetLocalSession();
        YuruUserEntity user = DBsession.get(YuruUserEntity.class, username);
        if (user == null) {
            judge = false;
        }
        try {
            ServerSocket server = new ServerSocket(16232);
            while(true){
                Socket s = server.accept();
                new Thread(new UploadThread(s, username, judge)).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

class UploadThread implements Runnable {
    private Socket s;
    private String username;
    private boolean judge;
    public UploadThread(Socket s,String username,boolean judge) {
        this.s = s;
        this.username = username;
        this.judge = judge;
    }

    @Override
    public void run() {
        String ip = s.getInetAddress().getHostAddress();
        System.out.println(ip+"...发来图片");
        try {
            BufferedInputStream bin = new BufferedInputStream(s.getInputStream());
            if(judge == false){
                OutputStream out = s.getOutputStream();
                out.write("#no_user".getBytes());
                s.close();
                return;
            }

            File dir = new File("./Icon/");
            if(!dir.exists()){
                dir.mkdir();
            }

            int count = 1;
            File file = new File(dir,username + ".jpg");

            while(file.exists()) {
                file = new File(dir,ip + "(" + (count++) + ")" + ".jpg");
            }

            FileOutputStream fout = new FileOutputStream(file);

            byte buf[] = new byte[1024];
            int len = 0;
            while((len = bin.read(buf)) != -1){
                fout.write(buf, 0, len);
            }

            OutputStream out = s.getOutputStream();
            out.write("#set_pic_success".getBytes());

            fout.close();
            s.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
