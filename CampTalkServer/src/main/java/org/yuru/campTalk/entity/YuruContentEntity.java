package org.yuru.campTalk.entity;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "yuru_content", schema = "camptalk", catalog = "")
public class YuruContentEntity {
    private String content;
    private String senderuid;
    private Timestamp timestamp;
    private String sentenceid;

    @Basic
    @Column(name = "content")
    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    @Basic
    @Column(name = "senderuid")
    public String getSenderuid() {
        return senderuid;
    }

    public void setSenderuid(String senderuid) {
        this.senderuid = senderuid;
    }

    @Basic
    @Column(name = "timestamp")
    public Timestamp getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

    @Id
    @Column(name = "sentenceid")
    public String getSentenceid() {
        return sentenceid;
    }

    public void setSentenceid(String sentenceid) {
        this.sentenceid = sentenceid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        YuruContentEntity that = (YuruContentEntity) o;

        if (content != null ? !content.equals(that.content) : that.content != null) return false;
        if (senderuid != null ? !senderuid.equals(that.senderuid) : that.senderuid != null) return false;
        if (timestamp != null ? !timestamp.equals(that.timestamp) : that.timestamp != null) return false;
        if (sentenceid != null ? !sentenceid.equals(that.sentenceid) : that.sentenceid != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = content != null ? content.hashCode() : 0;
        result = 31 * result + (senderuid != null ? senderuid.hashCode() : 0);
        result = 31 * result + (timestamp != null ? timestamp.hashCode() : 0);
        result = 31 * result + (sentenceid != null ? sentenceid.hashCode() : 0);
        return result;
    }
}
