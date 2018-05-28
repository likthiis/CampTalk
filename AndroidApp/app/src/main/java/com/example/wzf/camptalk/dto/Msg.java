package com.example.wzf.camptalk.dto;

public class Msg {
    private String content;
    private int type;
    public Msg(String content,int type){
        this.content=content;
        this.type=type;
    }
    public String getContent(){
        return content;
    }

    public int getType(){
        return type;
    }
}
