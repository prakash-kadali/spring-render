package com.example.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.entity.Employee;
import com.example.entity.LeaveRequest;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {
    List<LeaveRequest> findByEmployee(Employee employee);
    long countByStatus(String status);
    long countByEmployeeAndStatusAndStartDateBetween(Employee employee, String status, LocalDate startDate, LocalDate endDate);
	List<LeaveRequest> findByEmployeeAndStatus(Employee employee, String string);

}
