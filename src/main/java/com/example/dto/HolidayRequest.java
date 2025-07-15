package com.example.dto; // You might need to create this package

import java.time.LocalDate;

public class HolidayRequest {
    private LocalDate date;
    private String description;

    // IMPORTANT: Make sure you have a no-argument constructor for JSON deserialization
    public HolidayRequest() {
    }

    // Constructor with arguments (optional, but good practice)
    public HolidayRequest(LocalDate date, String description) {
        this.date = date;
        this.description = description;
    }

    // Getters and Setters (REQUIRED for Spring to map JSON fields)
    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "HolidayRequest{" +
               "date=" + date +
               ", description='" + description + '\'' +
               '}';
    }
}