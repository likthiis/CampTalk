package org.yuru.campTalk.entity;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "yuru_auth", schema = "camptalk", catalog = "")
public class YuruAuthEntity {
    private String token;
    private String uid;
    private Timestamp destroyTimestamp;
    private Timestamp destroytimestamp;

    @Basic
    @Column(name = "token")
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    @Id
    @Column(name = "uid")
    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    @Basic
    @Column(name = "destroy_timestamp")
    public Timestamp getDestroyTimestamp() {
        return destroyTimestamp;
    }

    public void setDestroyTimestamp(Timestamp destroyTimestamp) {
        this.destroyTimestamp = destroyTimestamp;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        YuruAuthEntity that = (YuruAuthEntity) o;

        if (token != null ? !token.equals(that.token) : that.token != null) return false;
        if (uid != null ? !uid.equals(that.uid) : that.uid != null) return false;
        if (destroyTimestamp != null ? !destroyTimestamp.equals(that.destroyTimestamp) : that.destroyTimestamp != null)
            return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = token != null ? token.hashCode() : 0;
        result = 31 * result + (uid != null ? uid.hashCode() : 0);
        result = 31 * result + (destroyTimestamp != null ? destroyTimestamp.hashCode() : 0);
        return result;
    }

    @Basic
    @Column(name = "destroytimestamp")
    public Timestamp getDestroytimestamp() {
        return destroytimestamp;
    }

    public void setDestroytimestamp(Timestamp destroytimestamp) {
        this.destroytimestamp = destroytimestamp;
    }
}
