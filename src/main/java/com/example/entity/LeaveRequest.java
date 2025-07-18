package com.example.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDate;
import lombok.Data; // Add this import
import lombok.NoArgsConstructor;
import lombok.ToString; // Add this import

@Entity
@Data // This will generate toString()
@NoArgsConstructor
public class LeaveRequest {

    
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "emp_id", nullable = false)
    @ToString.Exclude // <--- Exclude to prevent recursion
    private Employee employee;

    private LocalDate startDate;
    private LocalDate endDate;
    private String reason;
    private String status;
    private LocalDate requestDate;
    public LeaveRequest(Employee employee, LocalDate startDate, LocalDate endDate, String reason) {
        this.employee = employee;
        this.startDate = startDate;
        this.endDate = endDate;
        this.reason = reason;
        this.status = "PENDING";
        this.requestDate = LocalDate.now();
    }

    // You wouldn't need a manual toString() with @Data and @ToString.Exclude
    // The constructors remain as they are.
}