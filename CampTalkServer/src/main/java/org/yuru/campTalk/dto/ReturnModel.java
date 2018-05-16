package org.yuru.campTalk.dto;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : A data model which encapsulated to return.
 */
@XmlRootElement(name = "xml")
public class ReturnModel implements Serializable {
    private String code;
    private String timestamp;
    private String token = null;

    @XmlElement(name = "code")
    public String getCode() {
        return this.code;
    }
    public void setCode(String code) {
        this.code = code;
    }
    @XmlElement(name = "timestamp")
    public String getTimestamp() {
        return this.timestamp;
    }
    public void setTimestamp(String ts) {
        this.timestamp = ts;
    }
    @XmlElement(name = "token")
    public String getToken() {
        return token;
    }
    public void setToken(String token) {
        this.token = token;
    }

    public void specialDeal() {
        this.code = "exception_occurred";
        this.timestamp = new Timestamp(System.currentTimeMillis()).toString();
        this.token = null;
    }
}
