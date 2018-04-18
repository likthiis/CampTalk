package org.yuru.campTalk.dto;

import javax.xml.bind.annotation.XmlElement;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Class ReturnElement is used to encapsulate the real data which returned.
 */
//元素的数据结构
public class ReturnElement {

    /**
     * a token for authentication
     */
    private String sign;

    /**
     * exception message
     */
    private String message;

    /**
     * data to return
     */
    private String data;

    public ReturnElement() {
    }

    //下面这个是什么意思
    @XmlElement(required = false)
    //上面这个是什么意思

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    @XmlElement(required = false)
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    @XmlElement(required = false)
    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}
