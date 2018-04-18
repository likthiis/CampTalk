package org.yuru.campTalk.utility;
import org.apache.commons.codec.digest.DigestUtils;
import org.yuru.campTalk.GlobalConfigContext;


/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Methods for data encryption and authorization verification.
 */
public class EncryptUtil {

    /**
     * Encrypt a string using SHA256 with salt.
     * @param orgStr string to be encrypted
     * @return encrypted string
     */
    public static String EncryptSHA256(String orgStr) {
        return DigestUtils.sha256Hex(orgStr + GlobalConfigContext.AUTHORITY_SALT);
    }
    //盐值加密器。
    /**
     * Encrypt a string using SHA256 with custom salt.
     * @param orgStr string to be encrypted
     * @param salt custom salt string
     * @return encrypted string
     */
    public static String EncryptSHA256(String orgStr, String salt) {
        return DigestUtils.sha256Hex(orgStr + salt);
    }
}   //还是盐值加密器。
