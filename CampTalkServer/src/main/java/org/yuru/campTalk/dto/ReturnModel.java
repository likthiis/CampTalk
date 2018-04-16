package org.yuru.campTalk.dto;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.io.Serializable;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : A data model which encapsulated to return.
 */
@XmlRootElement(name = "xml")
public class ReturnModel implements Serializable {

    /**
     * Status code
     */
    private StatusCode code;

    /**
     * Service timestamp.
     */
    private String timestamp;

    /**
     * Element to return
     */
    private ReturnElement returnElement;

    @XmlElement(name = "code")
    public StatusCode getCode() {
        return this.code;
    }

    public void setCode(StatusCode code) {
        this.code = code;
    }

    @XmlElement(name = "timestamp")
    public String getTimestamp() {
        return this.timestamp;
    }

    public void setTimestamp(String ts) {
        this.timestamp = ts;
    }

    @XmlElement(name = "return")
    public ReturnElement getReturnElement() {
        return this.returnElement;
    }

    public void setReturnElement(ReturnElement returnElement) {
        this.returnElement = returnElement;
    }
}
