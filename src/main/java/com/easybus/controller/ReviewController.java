package com.easybus.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.easybus.model.ReviewRequest;
import com.easybus.model.ReviewResponse;
import com.easybus.service.ReviewService;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

	@Autowired
	private ReviewService reviewService;

	@PostMapping("/busreview")
	public ReviewResponse submitReview(@RequestBody ReviewRequest request) {
		return reviewService.addReview(request);
	}

	@GetMapping("/bus/{busId}")
	public List<ReviewResponse> getReviews(@PathVariable Long busId) {
		return reviewService.getReviewsByBus(busId);
	}
}
