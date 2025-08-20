package com.easybus.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.easybus.entity.User;
import com.easybus.model.ApiResponse;
import com.easybus.model.PagedResponse;
import com.easybus.service.UserService;

import jakarta.validation.Valid;

    @RestController
    @RequestMapping("/api/users")
    public class UserController {
    	   private static final Logger log = LoggerFactory.getLogger(UserController.class);
        private final UserService userService;

        public UserController(UserService userService) {
            this.userService = userService;
        }

        // ➤ CREATE SINGLE USER
        @PostMapping
        public ResponseEntity<ApiResponse<User>> createUser(@RequestBody @Valid User user) {
            User savedUser = userService.createUser(user);
            return ResponseEntity.ok(new ApiResponse<>("success", "User created successfully", savedUser));
        }

        // ➤ CREATE MULTIPLE USERS
        @PostMapping("/bulk")
        public ResponseEntity<ApiResponse<List<User>>> createUsers(@RequestBody @Valid List<User> users) {
        	  log.info("Creating user with email: {}", users);
            List<User> savedUsers = userService.createUsers(users);
            log.debug("Created user: {}", savedUsers);
            return ResponseEntity.ok(new ApiResponse<>("success", "Users created successfully", savedUsers));
        }

        // ➤ GET SINGLE USER
        @GetMapping("/{id}")
        public ResponseEntity<ApiResponse<User>> getUser(@PathVariable Long id) {
            User user = userService.getUser(id);
            return ResponseEntity.ok(new ApiResponse<>("success", "User retrieved successfully", user));
        }

        // ➤ GET ALL USERS
        @GetMapping
        public ResponseEntity<ApiResponse<List<User>>> getAllUsers() {
            List<User> users = userService.getAllUsers();
            return ResponseEntity.ok(new ApiResponse<>("success", "Users retrieved successfully", users));
        }

        // ➤ UPDATE SINGLE USER
        @PutMapping("/{id}")
        public ResponseEntity<ApiResponse<User>> updateUser(@PathVariable Long id, @RequestBody User user) {
            User updatedUser = userService.updateUser(id, user);
            return ResponseEntity.ok(new ApiResponse<>("success", "User updated successfully", updatedUser));
        }

        // ➤ UPDATE MULTIPLE USERS
        @PutMapping("/bulk-update")
        public ResponseEntity<ApiResponse<List<User>>> updateUsers(@RequestBody List<User> users) {
            log.info("API: bulkUpdateUsers count={}", users.size());
            List<User> updatedUsers = userService.updateUsers(users);
            return ResponseEntity.ok(new ApiResponse<>("success", "Users updated successfully", updatedUsers));
        }

        // ➤ DELETE SINGLE USER (soft delete)
        @DeleteMapping("/{id}")
        public ResponseEntity<ApiResponse<String>> deleteUser(@PathVariable Long id) {
            userService.softDeleteUser(id);
            return ResponseEntity.ok(new ApiResponse<>("success", "User deleted successfully", null));
        }

        // ➤ DELETE MULTIPLE USERS (soft delete)
        @DeleteMapping("/bulk-delete")
        public ResponseEntity<ApiResponse<String>> deleteUsers(@RequestParam List<Long> ids) {
        	 log.warn("API: bulkSoftDelete ids={}", ids);
            userService.softDeleteUsers(ids);
            return ResponseEntity.ok(new ApiResponse<>("success", "Users deleted successfully", null));
        }
    


    @GetMapping("/searchAll")
    public ResponseEntity<PagedResponse<User>> searchUsers(
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String phonNumber,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sortBy) {

    	 PagedResponse<User> users = userService.searchUsers(email, name, status,phonNumber, page, size, sortBy);
        return ResponseEntity.ok(users);
    }

    

}
