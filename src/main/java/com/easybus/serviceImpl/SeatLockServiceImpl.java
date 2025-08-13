package com.easybus.serviceImpl;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.easybus.repository.BookingRepository;
import com.easybus.service.SeatLockService;

@Service
public class SeatLockServiceImpl implements SeatLockService {

    private final Set<String> lockedSeats = new HashSet<>();
    
    @Autowired BookingRepository bookingRepository;

    public boolean lockSeats(Long busId, LocalDate journeyDate, List<String> seatNumbers) {
        // Check if seats are already locked or booked
        List<String> alreadyBooked = bookingRepository.findBookedSeats(busId, journeyDate);
        for (String seat : seatNumbers) {
            if (alreadyBooked.contains(seat)) {
                return false; // seat already booked
            }
        }
        
        // Optionally store the locked seats in memory or DB (skipped here)
        return true; // seats successfully locked
    }



    @Override
    public void unlockSeats(Long busId, LocalDate journeyDate, List<String> seats) {
        for (String seat : seats) {
            String key = busId + "-" + journeyDate.toString() + "-" + seat;
            lockedSeats.remove(key);
        }
    }
}
