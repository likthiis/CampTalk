package org.yuru.campTalk.entity;

import javax.persistence.*;

@Entity
@Table(name = "yuru_talk", schema = "camptalk", catalog = "")
public class YuruTalkEntity {
    private String backgroundPid;
    private String tid;

    @Basic
    @Column(name = "BackgroundPid")
    public String getBackgroundPid() {
        return backgroundPid;
    }

    public void setBackgroundPid(String backgroundPid) {
        this.backgroundPid = backgroundPid;
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

        YuruTalkEntity that = (YuruTalkEntity) o;

        if (backgroundPid != null ? !backgroundPid.equals(that.backgroundPid) : that.backgroundPid != null)
            return false;
        if (tid != null ? !tid.equals(that.tid) : that.tid != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = backgroundPid != null ? backgroundPid.hashCode() : 0;
        result = 31 * result + (tid != null ? tid.hashCode() : 0);
        return result;
    }
}
