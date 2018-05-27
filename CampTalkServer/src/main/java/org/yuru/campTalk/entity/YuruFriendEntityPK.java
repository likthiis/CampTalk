package org.yuru.campTalk.entity;

import javax.persistence.Column;
import javax.persistence.Id;
import java.io.Serializable;

public class YuruFriendEntityPK implements Serializable {
    private String name2;
    private String name1;

    @Column(name = "name2")
    @Id
    public String getName2() {
        return name2;
    }

    public void setName2(String name2) {
        this.name2 = name2;
    }

    @Column(name = "name1")
    @Id
    public String getName1() {
        return name1;
    }

    public void setName1(String name1) {
        this.name1 = name1;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        YuruFriendEntityPK that = (YuruFriendEntityPK) o;

        if (name2 != null ? !name2.equals(that.name2) : that.name2 != null) return false;
        if (name1 != null ? !name1.equals(that.name1) : that.name1 != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = name2 != null ? name2.hashCode() : 0;
        result = 31 * result + (name1 != null ? name1.hashCode() : 0);
        return result;
    }
}
