package org.yuru.campTalk.restful;

import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class testHome {
    @RequestMapping("/main")
    @ResponseBody
    @Transactional
    public String Home(){
        System.out.println("testHome is started!");
        return "Yokuso CampTalk!And have fun in CampTalk!";
    }
}
