package com.example.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.entity.User;

public interface UserRepository extends JpaRepository<User, Long> {
	Optional<User> findByEmailAndPasswordAndRole(String email, String password, String role);

	User findByEmail(String email);



}
