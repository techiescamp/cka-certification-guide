package com.example.staffregistry;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class StaffRegistryApplication {
    public static void main(String[] args) {
        SpringApplication.run(StaffRegistryApplication.class, args);
    }
}
