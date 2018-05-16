package org.yuru.campTalk.entity;

import javax.persistence.*;

@Entity
@Table(name = "yuru_clientid", schema = "camptalk", catalog = "")
public class YuruClientidEntity {
    private String clientid;
    private String uid;

    @Basic
    @Column(name = "clientid")
    public String getClientid() {
        return clientid;
    }

    public void setClientid(String clientid) {
        this.clientid = clientid;
    }

    @Id
    @Column(name = "uid")
    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        YuruClientidEntity that = (YuruClientidEntity) o;

        if (clientid != null ? !clientid.equals(that.clientid) : that.clientid != null) return false;
        if (uid != null ? !uid.equals(that.uid) : that.uid != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = clientid != null ? clientid.hashCode() : 0;
        result = 31 * result + (uid != null ? uid.hashCode() : 0);
        return result;
    }
}
