package com.easybus.serviceImpl;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import com.easybus.entity.User;
import com.easybus.entity.User.Status;
import com.easybus.model.PagedResponse;
import com.easybus.model.UserSpecification;
import com.easybus.repository.UserRepository;
import com.easybus.service.UserService;

@Service
public class UserServiceImpl implements UserService {

	private final UserRepository userRepository;
	private final ModelMapper modelMapper = new ModelMapper();

	public UserServiceImpl(UserRepository userRepository) {
		this.userRepository = userRepository;
	}

	@Override
	public User createUser(User user) {

		user.setStatus(User.Status.ACTIVE);// default active
		return userRepository.save(user);
	}

	@Override
	public User updateUser(Long id, User user) {
		User existingUser = userRepository.findById(id)
				.orElseThrow(() -> new RuntimeException("User not found with id " + id));

		modelMapper.map(user, existingUser); // auto maps all fields

		return userRepository.save(existingUser);
	}

	@Override
	public void softDeleteUser(Long id) {
		Optional<User> userOpt = userRepository.findById(id);
		if (userOpt.isPresent()) {
			User user = userOpt.get();

			user.setStatus(User.Status.INACTIVE);
			userRepository.save(user);
		} else {
			throw new RuntimeException("User not found with id " + id);
		}
	}

	@Override
	public List<User> getAllUsers() {
		return userRepository.findAll();
	}

	// --- Bulk ---
	@Override
	public List<User> createUsers(List<User> users) {
		List<String> emails = users.stream().map(User::getEmail).collect(Collectors.toList());
		List<User> existingEmails = userRepository.findByEmailIn(emails);

		if (!existingEmails.isEmpty()) {
			List<String> list = existingEmails.stream().map(User::getEmail).toList();

			throw new RuntimeException("These emails already exist: " + list);
		}
		LocalDateTime now = LocalDateTime.now();
		users.forEach(u -> {
			u.setStatus(User.Status.ACTIVE);
			u.setCreatedDate(now);
			u.setCreatedBy("system"); // replace with logged-in user if available
		});

		return userRepository.saveAll(users);
	}

	@Override
	public List<User> updateUsers(List<User> updateRequests) {
		List<User> updatedUsers = new ArrayList<>();

		for (User req : updateRequests) {
			User user = userRepository.findById(req.getId())
					.orElseThrow(() -> new RuntimeException("User not found with id " + req.getId()));

			// update only non-null fields
			if (req.getFullName() != null)
				user.setFullName(req.getFullName());
			if (req.getEmail() != null)
				user.setEmail(req.getEmail());
			if (req.getPhoneNumber() != null)
				user.setPhoneNumber(req.getPhoneNumber());
			if (req.getPasswordHash() != null)
				user.setPasswordHash(req.getPasswordHash());
			if (req.getStatus() != null)
				user.setStatus(req.getStatus());

			updatedUsers.add(user);
		}

		return userRepository.saveAll(updatedUsers);
	}

	@Override
	public void softDeleteUsers(List<Long> ids) {
		List<User> users = userRepository.findAllById(ids);

		if (users.isEmpty()) {
			throw new RuntimeException("No users found for given IDs");
		}

		users.forEach(user -> {

			user.setStatus(User.Status.INACTIVE); // mark as inactive
			user.setUpdatedDate(LocalDateTime.now());
			user.setUpdatedBy("system"); // or from logged-in user context
		});

		userRepository.saveAll(users); // bulk update
	}

	@Override
	public User getUser(Long id) { // 👈 Implementation
		return userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found with id " + id));
	}

	@Override
	public PagedResponse<User> searchUsers(String email, String name, String status, String phoneNumber, int page,
			int size, String sortBy) {
		Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy).ascending());
		Specification<User> spec = Specification.where(null); // start empty

		spec = spec.and(UserSpecification.hasEmail(email)).and(UserSpecification.hasName(name))
				.and(UserSpecification.hasStatus(status)).and(UserSpecification.hasPhoneNumber(phoneNumber));

		Page<User> userPage = userRepository.findAll(spec, pageable);

		return new PagedResponse<>(userPage.getContent(), userPage.getTotalPages(), userPage.getTotalElements(),
				userPage.getNumberOfElements());
	}
}
