package com.easybus.serviceImpl;


import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.easybus.entity.Review;
import com.easybus.model.ReviewRequest;
import com.easybus.model.ReviewResponse;
import com.easybus.repository.ReviewRepository;
import com.easybus.service.ReviewService;

@Service
public class ReviewServiceImpl implements ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    @Override
    public ReviewResponse addReview(ReviewRequest request) {
        Review review = new Review();
        review.setUserId(request.getUserId());
        review.setBusId(request.getBusId());
        review.setRating(request.getRating());
        review.setFeedback(request.getFeedback());

        Review saved = reviewRepository.save(review);

        ReviewResponse response = new ReviewResponse();
        response.setId(saved.getId());
        response.setUserId(saved.getUserId());
        response.setBusId(saved.getBusId());
        response.setRating(saved.getRating());
        response.setFeedback(saved.getFeedback());
        response.setMessage("Review submitted successfully!");

        return response;
    }

    @Override
    public List<ReviewResponse> getReviewsByBus(Long busId) {
        return reviewRepository.findByBusId(busId)
                .stream()
                .map(review -> {
                    ReviewResponse response = new ReviewResponse();
                    response.setId(review.getId());
                    response.setUserId(review.getUserId());
                    response.setBusId(review.getBusId());
                    response.setRating(review.getRating());
                    response.setFeedback(review.getFeedback());
                    response.setMessage("Success");
                    return response;
                })
                .collect(Collectors.toList());
    }
}

