
package com.example.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import java.time.LocalDate;

@Entity
public class LeaveRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "emp_id", nullable = false)
    private Employee employee; // The employee who is requesting leave

    private LocalDate startDate;
    private LocalDate endDate;
    private String reason;
    private String status; // "Pending", "Accepted", "Rejected"
    private LocalDate requestDate; // Date when the leave was requested

    // Constructors
    public LeaveRequest() {
        this.requestDate = LocalDate.now();
        this.status = "Pending"; // Default status
    }

    public LeaveRequest(Employee employee, LocalDate startDate, LocalDate endDate, String reason) {
        this.employee = employee;
        this.startDate = startDate;
        this.endDate = endDate;
        this.reason = reason;
        this.requestDate = LocalDate.now();
        this.status = "Pending";
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Employee getEmployee() {
        return employee;
    }

    public void setEmployee(Employee employee) {
        this.employee = employee;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDate getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(LocalDate requestDate) {
        this.requestDate = requestDate;
    }

    @Override
    public String toString() {
        return "LeaveRequest{" +
               "id=" + id +
               ", employee=" + employee.getName() + // To avoid recursion
               ", startDate=" + startDate +
               ", endDate=" + endDate +
               ", reason='" + reason + '\'' +
               ", status='" + status + '\'' +
               ", requestDate=" + requestDate +
               '}';
    }
}