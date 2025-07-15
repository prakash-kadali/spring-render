package com.example.repository; // Adjust package as per your project

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.example.entity.Holiday;

@Repository
public interface HolidayRepository extends JpaRepository<Holiday, Long> {

    // Custom query method to find holidays within a specific date range
    List<Holiday> findByDateBetween(LocalDate startDate, LocalDate endDate);

    // To check if a holiday for a specific date already exists
    Optional<Holiday> findByDate(LocalDate date);
    
    @Query("SELECT h.date FROM Holiday h WHERE h.date BETWEEN :start AND :end")
    List<LocalDate> findHolidayDatesBetween(LocalDate start, LocalDate end);
}
