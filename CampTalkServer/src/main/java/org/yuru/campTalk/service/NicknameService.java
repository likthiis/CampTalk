package org.yuru.campTalk.service;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.yuru.campTalk.entity.YuruUserEntity;
import org.yuru.campTalk.utility.HibernateUtil;

import java.io.IOException;

public class NicknameService {
    private static boolean CheckDuplicate(Session DBsession, String username, String nickname) {
        YuruUserEntity user = DBsession.get(YuruUserEntity.class, username);
        if(nickname.equals(user.getUsername())) {
            return true;
        }
        return false;
    }

    private static boolean DBChangeNickname(Session DBsession, String username, String nickname) {
        try {
            YuruUserEntity user = DBsession.get(YuruUserEntity.class, username);
            user.setUsername(nickname);
            DBsession.update(user);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static String ChangeNickname(String username, String nickname) {
        Session DBsession = HibernateUtil.GetLocalSession();
        Transaction transaction = DBsession.beginTransaction();
        try {
            boolean duplicate = false;
            duplicate = CheckDuplicate(DBsession, username, nickname);
            if(!duplicate) {
                boolean SQLsuccess = true;
                SQLsuccess = DBChangeNickname(DBsession, username, nickname);
                transaction.commit();
                if(SQLsuccess) {
                    return "#set_nickname_success";
                }
                if(!SQLsuccess) {
                    return "#exception_occurred";
                }
            }
            if(duplicate) {
                transaction.commit();
                return "#duplicate_nickname";
            }
            return "#other_error";
        } catch (Exception ex) {
            transaction.rollback();
            return "#exception_occurred";
        }
        finally {
            HibernateUtil.CloseLocalSession();
        }
    }
}
