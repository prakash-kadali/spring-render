package com.example.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.entity.Employee;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {
	List<Employee> findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCaseOrEmailContainingIgnoreCase(String firstName, String lastName, String email);
    List<Employee> findByEmpIdOrFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCaseOrEmailContainingIgnoreCase(Long empId, String firstName, String lastName, String email);
	Employee findByEmail(String email);
	@Query("SELECT e FROM Employee e WHERE " +
		       "CAST(e.empId AS string) LIKE %:query% OR " +
		       "LOWER(e.firstName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
		       "LOWER(e.email) LIKE LOWER(CONCAT('%', :query, '%'))")
		List<Employee> findByEmpIdOrNameOrEmailContaining(@Param("query") String query);

	
}
