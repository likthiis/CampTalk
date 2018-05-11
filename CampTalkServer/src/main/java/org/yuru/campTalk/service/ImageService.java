package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.HibernateUtil;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class ImageService {
    public static void DefaultPicture(String username) {
        try {
            String path = "./Icon/";
            String fileName = username + ".jpg";
            FileInputStream input=new FileInputStream("./Icon/default.jpg");
            FileOutputStream output=new FileOutputStream(path+fileName);

            int in=input.read();
            while(in!=-1) {
                output.write(in);
                in = input.read();
            }
            input.close();
            output.close();
        } catch (IOException e){
            System.out.println(e.toString());
        }
    }

    public static String ReceivePicture(String username,String extension) {
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
                UploadThread thread = new UploadThread(s, username + extension, judge);
                new Thread(thread).start();
                return thread.GetReturnString();
            }
        } catch (IOException e) {
            e.printStackTrace();
            return "#IOException_error";
        }
    }
}

class UploadThread implements Runnable {
    private Socket s;
    private String username;
    private String returnString = "#nothing";
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

            String path = "./Icon/";
            File dir = new File(path);
            if(!dir.exists()){
                dir.mkdir();
            }

            String fileName = username;
            File file = new File(dir,fileName);

            if(file.isFile()&&file.exists()) {
                file.delete();
                File newFile = new File(dir,fileName);
                newFile.createNewFile();
                String notice = TransferInFileOfPicture(newFile, bin);
                this.returnString = notice;
            } else {
                file.createNewFile();
                String notice = TransferInFileOfPicture(file, bin);
                this.returnString = notice;
            }
            s.close();
            this.returnString = "#other_error";
        } catch (IOException e) {
            e.printStackTrace();
            this.returnString = "#IOException_error";
        }
    }

    private String TransferInFileOfPicture(File file, BufferedInputStream bin){
        try {
            FileOutputStream fout = new FileOutputStream(file);
            byte buf[] = new byte[1024];
            int len = 0;
            while ((len = bin.read(buf)) != -1) {
                fout.write(buf, 0, len);
            }
            fout.close();
            return "#set_pic_success";
        } catch (IOException e) {
            e.printStackTrace();
            return "#IOException_error";
        }
    }

    public String GetReturnString(){
        return returnString;
    }
}
