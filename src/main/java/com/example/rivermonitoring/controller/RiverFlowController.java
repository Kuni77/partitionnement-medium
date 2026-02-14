package com.example.rivermonitoring.controller;

import com.example.rivermonitoring.dto.RiverFlowRequest;
import com.example.rivermonitoring.dto.RiverFlowResponse;
import com.example.rivermonitoring.service.RiverFlowService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/river-flows")
@RequiredArgsConstructor
public class RiverFlowController {

    private final RiverFlowService riverFlowService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void saveFlowMeasurements(@RequestBody List<RiverFlowRequest> measurements) {
        riverFlowService.saveFlowMeasurements(measurements);
    }

    @GetMapping("/{riverCode}")
    public List<RiverFlowResponse> getFlowsByRiver(
            @PathVariable String riverCode,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to) {

        if (from != null && to != null) {
            return riverFlowService.getFlowsByRiverAndPeriod(riverCode, from, to);
        }
        return riverFlowService.getFlowsByRiver(riverCode);
    }
}
