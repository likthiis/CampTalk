package org.yuru.campTalk;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.Banner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.orm.jpa.vendor.HibernateJpaSessionFactoryBean;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.yuru.campTalk.service.AuthorizationService;
import org.springframework.stereotype.*;

/**
 * Service Entry Point.
 */
/**
 * 服务端在这个文件里启动，换句话说就是主函数定义在此。
 */





@SpringBootApplication
@EnableTransactionManagement
@EntityScan(basePackages = "org.yuru.campTalk.entity")
public class CampTalkApp implements EmbeddedServletContainerCustomizer {
    //TODO:先实现从客户端发一条消息给服务端，服务端再发一条消息给客户端的吧。

    @RequestMapping("/")
    String home() {
        return "欢迎使用camptalk服务，祝您玩得愉快！";
    }

    public static void main(String[] args) throws Exception {
        SpringApplication.run(CampTalkApp.class, args);
    }

    @Override
    public void customize(ConfigurableEmbeddedServletContainer configurableEmbeddedServletContainer) {
        configurableEmbeddedServletContainer.setPort(16233);
    }

    @Bean
    public HibernateJpaSessionFactoryBean sessionFactory() {
        return new HibernateJpaSessionFactoryBean();
    }

}