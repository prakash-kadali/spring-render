package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;

import com.example.config.AuthFilter;

@SpringBootApplication
public class CompanyDashBoardApplication {

	public static void main(String[] args) {
		SpringApplication.run(CompanyDashBoardApplication.class, args);
	}
	@Bean
	public FilterRegistrationBean<AuthFilter> loggingFilter(){
	    FilterRegistrationBean<AuthFilter> registrationBean = new FilterRegistrationBean<>();
	    registrationBean.setFilter(new AuthFilter());
	    registrationBean.addUrlPatterns("/admin-dashboard", "/emp-dashboard");
	    return registrationBean;
	}


}
