package org.yuru.campTalk.entity;

import javax.persistence.Column;
import javax.persistence.Id;
import java.io.Serializable;

public class YuruRelationEntityPK implements Serializable {
    private String uid;
    private String tid;

    @Column(name = "uid")
    @Id
    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    @Column(name = "tid")
    @Id
    public String getTid() {
        return tid;
    }

    public void setTid(String tid) {
        this.tid = tid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        YuruRelationEntityPK that = (YuruRelationEntityPK) o;

        if (uid != null ? !uid.equals(that.uid) : that.uid != null) return false;
        if (tid != null ? !tid.equals(that.tid) : that.tid != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = uid != null ? uid.hashCode() : 0;
        result = 31 * result + (tid != null ? tid.hashCode() : 0);
        return result;
    }
}
