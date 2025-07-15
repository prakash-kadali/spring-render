package com.example.entity;

import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import lombok.Data;
@Data
@Entity
public class Designation {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="desig_id")
    private Long desigId;
    private String title;
    @Column(name="created_date")
    private LocalDate createdDate;
    private String dmail;

    @OneToMany(mappedBy = "desig")
    private List<Employee> employees;
}