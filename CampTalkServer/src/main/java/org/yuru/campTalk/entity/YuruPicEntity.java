package org.yuru.campTalk.entity;

import javax.persistence.*;

@Entity
@Table(name = "yuru_pic", schema = "camptalk", catalog = "")
public class YuruPicEntity {
    private String picpath;
    private String uid;

    @Basic
    @Column(name = "picpath")
    public String getPicpath() {
        return picpath;
    }

    public void setPicpath(String picpath) {
        this.picpath = picpath;
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

        YuruPicEntity that = (YuruPicEntity) o;

        if (picpath != null ? !picpath.equals(that.picpath) : that.picpath != null) return false;
        if (uid != null ? !uid.equals(that.uid) : that.uid != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = picpath != null ? picpath.hashCode() : 0;
        result = 31 * result + (uid != null ? uid.hashCode() : 0);
        return result;
    }
}
