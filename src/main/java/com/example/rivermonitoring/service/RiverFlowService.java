package com.example.rivermonitoring.service;

import com.example.rivermonitoring.dto.RiverFlowRequest;
import com.example.rivermonitoring.dto.RiverFlowResponse;
import com.example.rivermonitoring.entity.RiverFlow;
import com.example.rivermonitoring.repository.RiverFlowRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RiverFlowService {

    private final RiverFlowRepository riverFlowRepository;

    @Transactional
    public void saveFlowMeasurements(List<RiverFlowRequest> measurements) {
        for (RiverFlowRequest request : measurements) {
            riverFlowRepository.upsert(
                    request.getRiverCode(),
                    request.getMeasuredAt(),
                    request.getFlowRate()
            );
        }
    }

    @Transactional(readOnly = true)
    public List<RiverFlowResponse> getFlowsByRiver(String riverCode) {
        return riverFlowRepository.findByRiverCode(riverCode).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<RiverFlowResponse> getFlowsByRiverAndPeriod(String riverCode,
                                                             LocalDateTime from,
                                                             LocalDateTime to) {
        return riverFlowRepository.findByRiverCodeAndMeasuredAtBetween(riverCode, from, to)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private RiverFlowResponse toResponse(RiverFlow entity) {
        return RiverFlowResponse.builder()
                .id(entity.getId())
                .riverCode(entity.getRiverCode())
                .measuredAt(entity.getMeasuredAt())
                .flowRate(entity.getFlowRate())
                .receivedAt(entity.getReceivedAt())
                .build();
    }
}
