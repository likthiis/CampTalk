package org.yuru.campTalk.service;

/**
 * Author: likthiis
 * Date  : 2018/4/23
 * Usage : 聊天服务处理类
 */

public class ChatService {



    /**
     * 生成会话，并记录在数据库中
     * @param target 用户希望联系的朋友uid
     * @param myself 自己的uid
     * @return 暂时没想好
     */
    public static String RelationSetting(String target, String myself) {
        return "等着做";
    }

    /**
     * 接受信息，并记录在数据库中
     * @param target 用户希望联系的朋友uid
     * @param content 发送的内容
     * @param myself 发送的内容
     * @return 暂时没想好
     */
     public static String MessageGetting(String target, String content, String myself) {
         return "等着做";
     }

    /**
     * 接受信息，并记录在数据库中
     * @param target 用户希望联系的朋友uid
     * @param content 发送的内容
     * @return 暂时没想好
     */
    public static String MessageSend(String target, String content) {
        return "等着做";
    }

}
