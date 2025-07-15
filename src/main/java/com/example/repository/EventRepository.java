package com.example.repository;

import com.example.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface EventRepository extends JpaRepository<Event, Long> {
    // Find events within a date range
    List<Event> findByDateBetween(LocalDate startDate, LocalDate endDate);

    // Find all events for a specific date (optional, but good to have)
    List<Event> findByDate(LocalDate date);
}