package com.easybus.serviceImpl;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.easybus.entity.Bus;
import com.easybus.entity.Fare;
import com.easybus.entity.Seat;
import com.easybus.repository.BookingRepository;
import com.easybus.repository.BusRepository;
import com.easybus.repository.FareRepository;
import com.easybus.repository.SeatRepository;
import com.easybus.service.BusService;

@Service
public class BusServiceImpl implements BusService {

    @Autowired private BusRepository busRepository;
    @Autowired private SeatRepository seatRepository;
    @Autowired private FareRepository fareRepository;
    @Autowired private BookingRepository bookingRepository;

    @Override
    public List<Bus> searchBuses(String from, String to) {
        return busRepository.findBySourceAndDestination(from, to);
    }

    @Override
    public Optional<Bus> getBusDetails(Long id) {
        return busRepository.findById(id);
    }

    @Override
    public List<Seat> getSeatLayout(Long busId) {
        return seatRepository.findByBusId(busId);
    }

    @Override
    public long getSeatAvailability(Long busId) {
        return seatRepository.findByBusId(busId)
                .stream()
                .filter(Seat::isAvailable)
                .count();
    }

    @Override
    public Fare getFareDetails(Long busId) {
        return fareRepository.findByBusId(busId);
    }

    // ✅ Now dynamic
    @Override
    public List<String> getPopularRoutes() {
        return bookingRepository.findTopPopularRoutes();
    }
}
