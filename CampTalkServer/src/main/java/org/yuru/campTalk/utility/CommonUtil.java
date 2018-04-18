package org.yuru.campTalk.utility;

import java.util.HashMap;
import java.util.List;
import java.util.Random;

/**
 * Author: Rinkako
 * Date  : 2018/4/16
 * Usage : Some useful helper methods.
 */
//标准基础设施仓库。


public class CommonUtil {
    /**
     * Check if a string is null or empty.
     * @param str string to be checked
     * @return boolean of result
     */
    public static boolean IsNullOrEmpty(String str) {
        return str == null || str.equals("");
    }
    //判断是不是空字符串。
    /**
     * Generate a random number in interval of [min, max)
     * @param min low border included
     * @param max up border not included
     * @return a random number in interval
     */
    public static int GenerateRandomNumber(int min, int max) {
        Random rand = new Random();
        return rand.nextInt(max - min) + min;
    }
    //生成随机数字。
    /**
     * Zip a key vector and a value vector to a hash map.
     * Key list and value list should have same size.
     * @param keyList key vector, all entry should be unique
     * @param valueList value vector
     * @param <TyK> Key type
     * @param <TyV> Value type
     * @return A HashMap for (key, value)
     */
    public static <TyK, TyV> HashMap<TyK, TyV> ZipVector(List<TyK> keyList, List<TyV> valueList) {
        if (keyList == null || valueList == null) {
            return null;
        }
        assert keyList.size() == valueList.size();
        HashMap<TyK, TyV> retMap = new HashMap<>();
        for (int i = 0; i < keyList.size(); i++) {
            retMap.put(keyList.get(i), valueList.get(i));
        }
        return retMap;
    }
    //键值对转哈希表。
    /**
     * Zip a key vector and a value vector to a hash map in all string type.
     * Key list and value list should have same size.
     * @param keyList key vector, all entry should be unique
     * @param valueList value vector
     * @return A HashMap for (key, value)
     */
    public static HashMap<String, String> ZipVectorConvertString(List keyList, List valueList) {
        if (keyList == null || valueList == null) {
            return null;
        }
        assert keyList.size() == valueList.size();
        HashMap<String, String> retMap = new HashMap<>();
        for (int i = 0; i < keyList.size(); i++) {
            retMap.put(keyList.get(i).toString(), valueList.get(i).toString());
        }
        return retMap;
    }
    //键值对转哈希表，不过是转成string类型的(方便处理)。
}
