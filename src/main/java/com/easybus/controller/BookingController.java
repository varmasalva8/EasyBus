package com.easybus.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.easybus.model.BookingRequest;
import com.easybus.model.BookingResponse;
import com.easybus.model.RescheduleRequest;
import com.easybus.service.BookingService;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    @Autowired
    private BookingService bookingService;

    // ✅ Book Ticket
    @PostMapping("/book")
    public ResponseEntity<BookingResponse> bookTicket(@RequestBody BookingRequest request) {
        BookingResponse response = bookingService.bookTicket(request);
        return ResponseEntity.ok(response);
    }

    // ❌ Cancel Ticket
    @DeleteMapping("/cancel/{bookingId}")
    public ResponseEntity<String> cancelTicket(@PathVariable Long bookingId) {
        bookingService.cancelTicket(bookingId);
        return ResponseEntity.ok("Booking cancelled successfully.");
    }

    // 🔁 Reschedule Ticket
    @PutMapping("/reschedule/{bookingId}")
    public ResponseEntity<BookingResponse> rescheduleTicket(
            @PathVariable Long bookingId,
            @RequestBody RescheduleRequest request) {
        BookingResponse response = bookingService.rescheduleTicket(bookingId, request);
        return ResponseEntity.ok(response);
    }
}

