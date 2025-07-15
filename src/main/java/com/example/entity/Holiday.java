package com.example.entity; // Adjust package as per your project

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "holidays") // Define your table name
public class Holiday {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true) // Holiday date should be unique
    private LocalDate date;

    @Column(nullable = false)
    private String description;

    // Default constructor for JPA
    public Holiday() {
    }

    public Holiday(LocalDate date, String description) {
        this.date = date;
        this.description = description;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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
        return "Holiday{" +
               "id=" + id +
               ", date=" + date +
               ", description='" + description + '\'' +
               '}';
    }
}