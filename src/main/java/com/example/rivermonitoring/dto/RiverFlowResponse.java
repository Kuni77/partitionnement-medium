package com.example.rivermonitoring.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RiverFlowResponse {

    private Long id;
    private String riverCode;
    private LocalDateTime measuredAt;
    private Double flowRate;
    private LocalDateTime receivedAt;
}
