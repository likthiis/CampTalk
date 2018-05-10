package com.example.wzf.camptalk.utility;

import com.example.wzf.camptalk.dto.GetModel;
import com.google.gson.Gson;
import java.util.ArrayList;
import java.util.List;

public class JsonUtil {
    public static GetModel getJsonToModel (String jsondata) {
        Gson gson = new Gson();
        GetModel getModel = gson.fromJson(jsondata, GetModel.class);
        return getModel;
    }
}
