package com.easybus.controller;

import com.easybus.entity.User;
import com.easybus.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    // Single User Create
    @PostMapping("/create")
    public ResponseEntity<User> createUser(@RequestBody User user) {
        if (user.getIsActive() == null) {
            user.setIsActive(true); // default true
        }
        return ResponseEntity.ok(userService.createUser(user));
    }

    // Bulk Users Create
    @PostMapping("/create-bulk")
    public ResponseEntity<List<User>> createBulkUsers(@RequestBody List<User> users) {
        users.forEach(user -> {
            if (user.getIsActive() == null) {
                user.setIsActive(true);
            }
        });
        return ResponseEntity.ok(users.stream()
                .map(userService::createUser)
                .collect(Collectors.toList())); // Java 8 friendly
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        return ResponseEntity.ok(userService.updateUser(id, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> softDeleteUser(@PathVariable Long id) {
        userService.softDeleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<List<User>> getUsers(
            @RequestParam(required = false) Long id,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String phone
    ) {
        return ResponseEntity.ok(userService.getUsers(id, email, phone));
    }

    @GetMapping("/search")
    public ResponseEntity<List<User>> searchUsers(
            @RequestParam(required = false) Long id,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String phone
    ) {
        List<User> users = userService.searchUsers(id, email, phone);
        if (users.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(users);
    }

}
