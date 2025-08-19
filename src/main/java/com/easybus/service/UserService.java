package com.easybus.service;

import java.util.List;

import com.easybus.entity.User;

public interface UserService {

    // Single operations
    User createUser(User user);

    User updateUser(Long id, User user);

    void softDeleteUser(Long id);

    List<User> getAllUsers();

    // Bulk operations
    List<User> createUsers(List<User> users);

    List<User> updateUsers(List<User> users);

    void softDeleteUsers(List<Long> ids);
    List<User> searchUsers();
    User getUser(Long id);
}
