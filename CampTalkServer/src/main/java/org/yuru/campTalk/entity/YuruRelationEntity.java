package org.yuru.campTalk.entity;

import javax.persistence.*;

@Entity
@Table(name = "yuru_relation", schema = "camptalk", catalog = "")
@IdClass(YuruRelationEntityPK.class)
public class YuruRelationEntity {
    private String uid;
    private String tid;

    @Id
    @Column(name = "uid")
    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    @Id
    @Column(name = "tid")
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

        YuruRelationEntity that = (YuruRelationEntity) o;

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
