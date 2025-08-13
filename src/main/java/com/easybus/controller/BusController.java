package com.easybus.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.easybus.entity.Bus;
import com.easybus.entity.Fare;
import com.easybus.entity.Seat;
import com.easybus.service.BusService;

@RestController
@RequestMapping("/api/buses")
public class BusController {

	 @Autowired BusService busService;

    // 1. Search buses by source & destination
    @GetMapping("/search")
    public ResponseEntity<List<Bus>> searchBuses(
            @RequestParam String from,
            @RequestParam String to) {
        return ResponseEntity.ok(busService.searchBuses(from, to));
    }

    // 2. Get bus details
    @GetMapping("/{id}")
    public ResponseEntity<Bus> getBusDetails(@PathVariable Long id) {
        return busService.getBusDetails(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. Get seat layout
    @GetMapping("/{id}/seats")
    public ResponseEntity<List<Seat>> getSeatLayout(@PathVariable Long id) {
        return ResponseEntity.ok(busService.getSeatLayout(id));
    }

    // 4. Check seat availability
    @GetMapping("/{id}/availability")
    public ResponseEntity<Long> getSeatAvailability(@PathVariable Long id) {
        return ResponseEntity.ok(busService.getSeatAvailability(id));
    }

    // 5. Get fare details
    @GetMapping("/{id}/fares")
    public ResponseEntity<Fare> getFareDetails(@PathVariable Long id) {
        return ResponseEntity.ok(busService.getFareDetails(id));
    }

    // 6. Get popular routes
    @GetMapping("/routes/popular")
    public ResponseEntity<List<String>> getPopularRoutes() {
        return ResponseEntity.ok(busService.getPopularRoutes());
    }
}
