package org.yuru.campTalk.entity;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "yuru_user", schema = "camptalk", catalog = "")
public class YuruUserEntity {
    private String id;
    private String username;
    private Integer level;
    private String password;
    private Integer status;
    private Timestamp createtimestamp;
    private Timestamp lastlogin;
    private String location;
    private String headpid;

    @Id
    @Column(name = "id")
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    @Basic
    @Column(name = "username")
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Basic
    @Column(name = "level")
    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    @Basic
    @Column(name = "password")
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Basic
    @Column(name = "status")
    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    @Basic
    @Column(name = "createtimestamp")
    public Timestamp getCreatetimestamp() {
        return createtimestamp;
    }

    public void setCreatetimestamp(Timestamp createtimestamp) {
        this.createtimestamp = createtimestamp;
    }

    @Basic
    @Column(name = "lastlogin")
    public Timestamp getLastlogin() {
        return lastlogin;
    }

    public void setLastlogin(Timestamp lastlogin) {
        this.lastlogin = lastlogin;
    }

    @Basic
    @Column(name = "location")
    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    @Basic
    @Column(name = "headpid")
    public String getHeadpid() {
        return headpid;
    }

    public void setHeadpid(String headpid) {
        this.headpid = headpid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        YuruUserEntity that = (YuruUserEntity) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (username != null ? !username.equals(that.username) : that.username != null) return false;
        if (level != null ? !level.equals(that.level) : that.level != null) return false;
        if (password != null ? !password.equals(that.password) : that.password != null) return false;
        if (status != null ? !status.equals(that.status) : that.status != null) return false;
        if (createtimestamp != null ? !createtimestamp.equals(that.createtimestamp) : that.createtimestamp != null)
            return false;
        if (lastlogin != null ? !lastlogin.equals(that.lastlogin) : that.lastlogin != null) return false;
        if (location != null ? !location.equals(that.location) : that.location != null) return false;
        if (headpid != null ? !headpid.equals(that.headpid) : that.headpid != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (username != null ? username.hashCode() : 0);
        result = 31 * result + (level != null ? level.hashCode() : 0);
        result = 31 * result + (password != null ? password.hashCode() : 0);
        result = 31 * result + (status != null ? status.hashCode() : 0);
        result = 31 * result + (createtimestamp != null ? createtimestamp.hashCode() : 0);
        result = 31 * result + (lastlogin != null ? lastlogin.hashCode() : 0);
        result = 31 * result + (location != null ? location.hashCode() : 0);
        result = 31 * result + (headpid != null ? headpid.hashCode() : 0);
        return result;
    }
}
