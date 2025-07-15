package com.example.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.entity.Designation;

public interface DesignationRepository extends JpaRepository<Designation, Long> {

	List<Designation> findAll();
}
