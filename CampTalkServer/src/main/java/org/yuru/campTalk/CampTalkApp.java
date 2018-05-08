package org.yuru.campTalk;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.embedded.ConfigurableEmbeddedServletContainer;
import org.springframework.boot.context.embedded.EmbeddedServletContainerCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.orm.jpa.vendor.HibernateJpaSessionFactoryBean;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Service Entry Point.
 */
@SpringBootApplication
@EnableTransactionManagement
//@ComponentScan(basePackages = "org.yuru.campTalk.service")
public class CampTalkApp implements EmbeddedServletContainerCustomizer {
    /**
     * In the view of programmer,the infomation coming from a user should
     * be written in database of server and be sent to another user by
     * server.
     */
    @RequestMapping("/home")
    String home() {
        return "Yokuso CampTalk!And have fun in CampTalk!";
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