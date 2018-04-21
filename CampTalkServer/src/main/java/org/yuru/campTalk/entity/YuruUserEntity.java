package org.yuru.campTalk.entity;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.Objects;

/**
 * Author: Rinkako
 * Date  : 2018/4/21
 * Usage :
 */
@Entity
@Table(name = "yuru_user", schema = "camptalk", catalog = "")
public class YuruUserEntity {
    private String id;
    private String username;
    private int level;
    private String password;
    private int status;
    private Timestamp createtimestamp;
    private Timestamp lastlogin;
    private String location;
    private String headPid;

    @Id
    @Column(name = "id", nullable = false, length = 255)
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    @Basic
    @Column(name = "username", nullable = false, length = 255)
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    @Basic
    @Column(name = "level", nullable = false)
    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    @Basic
    @Column(name = "password", nullable = false, length = 255)
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Basic
    @Column(name = "status", nullable = false)
    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    @Basic
    @Column(name = "createtimestamp", nullable = true)
    public Timestamp getCreatetimestamp() {
        return createtimestamp;
    }

    public void setCreatetimestamp(Timestamp createtimestamp) {
        this.createtimestamp = createtimestamp;
    }

    @Basic
    @Column(name = "lastlogin", nullable = true)
    public Timestamp getLastlogin() {
        return lastlogin;
    }

    public void setLastlogin(Timestamp lastlogin) {
        this.lastlogin = lastlogin;
    }

    @Basic
    @Column(name = "location", nullable = true, length = 255)
    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    @Basic
    @Column(name = "headPid", nullable = true, length = 255)
    public String getHeadPid() {
        return headPid;
    }

    public void setHeadPid(String headPid) {
        this.headPid = headPid;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        YuruUserEntity that = (YuruUserEntity) o;
        return level == that.level &&
                status == that.status &&
                Objects.equals(id, that.id) &&
                Objects.equals(username, that.username) &&
                Objects.equals(password, that.password) &&
                Objects.equals(createtimestamp, that.createtimestamp) &&
                Objects.equals(lastlogin, that.lastlogin) &&
                Objects.equals(location, that.location) &&
                Objects.equals(headPid, that.headPid);
    }

    @Override
    public int hashCode() {

        return Objects.hash(id, username, level, password, status, createtimestamp, lastlogin, location, headPid);
    }
}
