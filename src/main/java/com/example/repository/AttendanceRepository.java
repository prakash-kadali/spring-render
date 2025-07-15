package com.example.repository;

import com.example.entity.Attendance;
import com.example.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    // Find attendance record for a specific employee on a specific date
    Optional<Attendance> findByEmployeeAndAttendanceDate(Employee employee, LocalDate attendanceDate);
    long countByEmployeeAndAttendanceDateBetweenAndPresentTrue(Employee employee, LocalDate startDate, LocalDate endDate);

}