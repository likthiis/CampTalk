package org.yuru.campTalk;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Global configurations constant context.
 */
public class GlobalConfigContext {

    /**
     * Salt of password string.
     */
    public static final String AUTHORITY_SALT = "YuruCamp";

    /**
     * Valid duration of authorization token.
     */
    public static final Long AUTHORITY_TOKEN_VALID_SECOND = 2 * 60 * 60L;
    //public static final Long AUTHORITY_TOKEN_VALID_SECOND = 20L;
}
