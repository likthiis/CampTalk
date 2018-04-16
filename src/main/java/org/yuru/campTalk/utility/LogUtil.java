package org.yuru.campTalk.utility;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Static methods for resource service internal logging.
 */
public final class LogUtil {
    /**
     * Show a structure information message.
     * @param msg message text
     * @param label message label
     */
    public static void Echo(String msg, String label) {
        LogUtil.Echo(msg, label, LogLevelType.INFO);
    }

    /**
     * Show a structure message.
     * @param msg message text
     * @param label message label
     * @param level message level
     */
    public static void Echo(String msg, String label, LogLevelType level) {
        String printStr = String.format("[%s]%s-%s: %s", level.name(), TimestampUtil.GetTimestampString(), label, msg);
        System.out.println(printStr);
    }

    /**
     * Log a structure information message to steady.
     * @param msg message text
     * @param label message label
     */
    public static void Log(String msg, String label, String rtid) {
        LogUtil.Log(msg, label, LogLevelType.INFO, rtid);
    }

    /**
     * Log a structure message to steady.
     * @param msg message text
     * @param label message label
     * @param level message level
     * @param rtid process rtid
     */
    public static void Log(String msg, String label, LogLevelType level, String rtid) {
        LogUtil.ActualLog(msg, label, level, rtid, 0);
    }

    /**
     * Write log to steady.
     * @param msg message text
     * @param label message label
     * @param level message level
     * @param depth exception depth
     */
    private static void ActualLog(String msg, String label, LogLevelType level, String rtid, int depth) {
        LogUtil.Echo(msg, label, level);
    }
}
