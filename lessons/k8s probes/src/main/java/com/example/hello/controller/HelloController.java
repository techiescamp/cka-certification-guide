package com.example.hello.controller;

import com.example.hello.service.DatabaseConnectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.MediaType;

@RestController
public class HelloController {

    private final DatabaseConnectionService databaseConnectionService;

    @Autowired
    public HelloController(DatabaseConnectionService databaseConnectionService) {
        this.databaseConnectionService = databaseConnectionService;
    }

    @GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE)
    public String hello() {
        return """
            <!DOCTYPE html>
            <html>
            <head>
                <title>Hello World</title>
                <style>
                    body {
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        height: 100vh;
                        margin: 0;
                        font-family: Arial, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    }
                    h1 {
                        color: white;
                        font-size: 4rem;
                        text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                    }
                </style>
            </head>
            <body>
                <h1>Hello World!</h1>
            </body>
            </html>
            """;
    }

    @GetMapping("/api/status")
    public String status() {
        return "{\"databaseConnected\":" + databaseConnectionService.isDatabaseConnected() + ",\"message\":\"Hello World!\"}";
    }
}
