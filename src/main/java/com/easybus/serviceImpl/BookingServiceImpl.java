package com.easybus.serviceImpl;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.easybus.entity.Booking;
import com.easybus.entity.Bus;
import com.easybus.exceptions.ResourceNotFoundException;
import com.easybus.model.BookingRequest;
import com.easybus.model.BookingResponse;
import com.easybus.model.RescheduleRequest;
import com.easybus.repository.BookingRepository;
import com.easybus.repository.BusRepository;
import com.easybus.service.BookingService;
import com.easybus.service.SeatLockService;

import jakarta.transaction.Transactional;

@Service
public class BookingServiceImpl implements BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private BusRepository busRepository;

    @Autowired
    private SeatLockService seatLockService;

    @Transactional
    @Override
    public BookingResponse bookTicket(BookingRequest request) {
        // 1. Fetch Bus
        Bus bus = busRepository.findById(request.getBusId())
                .orElseThrow(() -> new ResourceNotFoundException("Bus not found with id: " + request.getBusId()));

        // 2. Check already booked seats
        List<String> alreadyBookedSeats = bookingRepository
                .findBookedSeats(bus.getId(), request.getJourneyDate());

        for (String seat : request.getSeatNumbers()) {
            if (alreadyBookedSeats.contains(seat)) {
                throw new IllegalArgumentException("Seat " + seat + " already booked");
            }
        }

        // 3. Lock seats
        boolean locked = seatLockService.lockSeats(bus.getId(), request.getJourneyDate(), request.getSeatNumbers());
        if (!locked) {
            throw new RuntimeException("Failed to lock seats. Please try again.");
        }

        // 4. Fare calculation
        double fare = request.getSeatNumbers().size() * bus.getFare();

        // 5. Create booking object
        Booking booking = new Booking();
        booking.setUserId(request.getUserId());
        booking.setBus(bus);
        booking.setSeatNumbers(String.join(",", request.getSeatNumbers()));
        booking.setJourneyDate(request.getJourneyDate());
        booking.setBoardingPoint(request.getBoardingPoint());
        booking.setDroppingPoint(request.getDroppingPoint());
        booking.setStatus("CONFIRMED");
        booking.setPnr(generatePNR());
        booking.setTotalFare(fare);

        bookingRepository.save(booking);

        // ✅ Avoid lazy loading by passing bus object directly
        return mapToResponse(booking, bus);
    }

    @Transactional
    @Override
    public void cancelTicket(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        booking.setStatus("CANCELLED");
        bookingRepository.save(booking);

        seatLockService.unlockSeats(
                booking.getBus().getId(),
                booking.getJourneyDate(),
                Arrays.asList(booking.getSeatNumbers().split(","))
        );
    }

    @Transactional
    @Override
    public BookingResponse rescheduleTicket(Long bookingId, RescheduleRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        Bus newBus = busRepository.findById(request.getNewBusId())
                .orElseThrow(() -> new ResourceNotFoundException("New bus not found"));

        List<String> alreadyBookedSeats = bookingRepository
                .findBookedSeats(newBus.getId(), request.getNewJourneyDate());

        for (String seat : request.getNewSeatNumbers()) {
            if (alreadyBookedSeats.contains(seat)) {
                throw new IllegalArgumentException("Seat " + seat + " already booked");
            }
        }

        boolean locked = seatLockService.lockSeats(newBus.getId(), request.getNewJourneyDate(), request.getNewSeatNumbers());
        if (!locked) {
            throw new RuntimeException("Failed to lock new seats. Please try again.");
        }

        seatLockService.unlockSeats(
                booking.getBus().getId(),
                booking.getJourneyDate(),
                Arrays.asList(booking.getSeatNumbers().split(","))
        );

        booking.setBus(newBus);
        booking.setSeatNumbers(String.join(",", request.getNewSeatNumbers()));
        booking.setJourneyDate(request.getNewJourneyDate());
        booking.setStatus("RESCHEDULED");
        booking.setTotalFare(request.getNewSeatNumbers().size() * newBus.getFare());

        bookingRepository.save(booking);

        // ✅ Pass newBus to avoid null busName
        return mapToResponse(booking, newBus);
    }

    private String generatePNR() {
        return "PNR" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }

    // ✅ Updated to accept Bus object directly
    private BookingResponse mapToResponse(Booking booking, Bus bus) {
        BookingResponse response = new BookingResponse();
        response.setBookingId(booking.getId());
        response.setPnr(booking.getPnr());
        response.setBusName(bus.getName()); // ✅ Always present
        response.setStatus(booking.getStatus());
        response.setSeatNumbers(Arrays.asList(booking.getSeatNumbers().split(",")));
        response.setTotalFare(booking.getTotalFare());
        response.setJourneyDate(booking.getJourneyDate());
        response.setMessage("Booking processed successfully");
        return response;
    }
}
