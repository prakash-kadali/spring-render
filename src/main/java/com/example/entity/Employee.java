package com.example.entity;

import java.time.LocalDate;

import jakarta.persistence.CascadeType; // ADD THIS IMPORT if using CascadeType
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne; // ADD THIS IMPORT
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
public class Employee {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="emp_id")
    private Long empId;
    private String name;

    @ManyToOne(optional = false)
    @JoinColumn(name = "dept_id", nullable = false)
    private Department dept;

    @ManyToOne(optional = false)
    @JoinColumn(name = "desig_id", nullable = false)
    private Designation desig;
    private String email;
    private Long phone;
    private LocalDate hiredate;
    @Column(name="first_name")
    private String firstName;
    @Column(name="last_name")
    private String lastName;
    private Double salary;
    @Column(name="account_number")
    private Long accountNumber;

    @Column(name="photo_url")
    private String photoUrl;

    // This is the inverse side of the One-to-One relationship.
    // 'mappedBy' indicates that the 'employee' field in the 'User' entity is the owning side.
    // CascadeType.ALL is often useful if you want User operations to affect Employee.
    // optional = true allows an Employee to exist without a linked User account.
    @OneToOne(mappedBy = "employee", cascade = CascadeType.ALL, optional = true)
    private User user;

    // Lombok's @Data will handle getters and setters.
}