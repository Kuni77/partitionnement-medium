package com.example.rivermonitoring.controller;

import com.example.rivermonitoring.dto.RiverFlowRequest;
import com.example.rivermonitoring.service.RiverFlowService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@RestController
@RequestMapping("/api/generate")
@RequiredArgsConstructor
@Slf4j
public class DataGeneratorController {

    private final RiverFlowService riverFlowService;
    private final Random random = new Random();

    @PostMapping
    public String generateData(
            @RequestParam(defaultValue = "1000") int rivers,
            @RequestParam(defaultValue = "365") int days) {

        LocalDateTime startDate = LocalDateTime.now().minusDays(days);
        int measurementsPerDay = 144; // every 10 minutes
        int totalInserted = 0;

        for (int r = 1; r <= rivers; r++) {
            List<RiverFlowRequest> batch = new ArrayList<>();

            for (int d = 0; d < days; d++) {
                for (int m = 0; m < measurementsPerDay; m++) {
                    LocalDateTime measuredAt = startDate
                            .plusDays(d)
                            .plusMinutes(m * 10L);

                    double flowRate = 100 + random.nextDouble() * 900; // 100-1000 m3/s

                    batch.add(RiverFlowRequest.builder()
                            .riverCode("RIVER_" + String.format("%04d", r))
                            .measuredAt(measuredAt)
                            .flowRate(flowRate)
                            .build());

                    // Flush batch every 1000 records to avoid memory issues
                    if (batch.size() >= 1000) {
                        riverFlowService.saveFlowMeasurements(batch);
                        totalInserted += batch.size();
                        batch.clear();
                    }
                }
            }

            // Flush remaining
            if (!batch.isEmpty()) {
                riverFlowService.saveFlowMeasurements(batch);
                totalInserted += batch.size();
            }

            if (r % 100 == 0) {
                log.info("Generated data for {}/{} rivers ({} records so far)", r, rivers, totalInserted);
            }
        }

        return String.format("Generated %d records for %d rivers over %d days", totalInserted, rivers, days);
    }
}
