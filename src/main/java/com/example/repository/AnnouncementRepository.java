package com.example.repository;

import com.example.entity.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {
    // Custom method to find active announcements, ordered by creation date (newest first)
    List<Announcement> findByActiveTrueOrderByCreatedAtDesc();
}