package com.example.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn; // ADD THIS IMPORT
import jakarta.persistence.OneToOne; // ADD THIS IMPORT
import jakarta.persistence.Table;
import lombok.Data;
import lombok.ToString;

@Entity
@Data
@Table(name="users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="user_id")
    private Long userId;
    private String username;
    private String password;
    private String role; // ADMIN or EMPLOYEE
    private String email;

    // Define the One-to-One relationship.
    // This is the owning side, meaning the 'users' table will have the foreign key.
    @OneToOne
    @JoinColumn(name = "employee_emp_id", referencedColumnName = "emp_id", unique = true)
    @ToString.Exclude
    // 'unique = true' is important here because one User links to one Employee, and vice-versa.
    // Also, setting nullable to false would mean every user must be linked to an employee.
    // For now, let's keep it nullable if some users (like admin) won't have an employee link.
    // If only 'employee' roles have this link, then validate in controller, not here.
    private Employee employee;

    // Lombok's @Data will handle getters and setters.
}