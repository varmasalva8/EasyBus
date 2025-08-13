package com.easybus.serviceImpl;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import com.easybus.entity.User;
import com.easybus.repository.UserRepository;
import com.easybus.service.UserService;
import com.easybus.specification.UserSpecification; 

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public User createUser(User user) {
        user.setIsActive(true); // default active
        return userRepository.save(user);
    }

    @Override
    public User updateUser(Long id, User user) {
        return userRepository.findById(id)
                .map(existing -> {
                    existing.setName(user.getName());
                    existing.setEmail(user.getEmail());
                    existing.setPhone(user.getPhone());
                    existing.setUpdateDate(java.time.LocalDateTime.now());
                    return userRepository.save(existing);
                })
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    @Override
    public void softDeleteUser(Long id) {
        userRepository.findById(id).ifPresent(user -> {
            user.setIsActive(false);
            user.setUpdateDate(java.time.LocalDateTime.now());
            userRepository.save(user);
        });
    }

    @Override
    public List<User> getUsers(Long id, String email, String phone) {
        Specification<User> spec = Specification.where(UserSpecification.isActive())
                .and(UserSpecification.hasId(id))
                .and(UserSpecification.hasEmail(email))
                .and(UserSpecification.hasPhone(phone));

        return userRepository.findAll(spec);
    }

    @Override
    public List<User> searchUsers(Long id, String email, String phone) {
        return userRepository.findAll(
                Specification.where(UserSpecification.hasId(id))
                        .and(UserSpecification.hasEmail(email))
                        .and(UserSpecification.hasPhone(phone))
                        .and(UserSpecification.isActive())
        );
    }

}
