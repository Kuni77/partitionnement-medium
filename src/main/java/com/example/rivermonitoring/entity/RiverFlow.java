package com.example.rivermonitoring.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "river_flow")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RiverFlow {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "river_code", nullable = false, length = 50)
    private String riverCode;

    @Column(name = "measured_at", nullable = false)
    private LocalDateTime measuredAt;

    @Column(name = "flow_rate", nullable = false)
    private Double flowRate;

    @Column(name = "received_at", nullable = false)
    private LocalDateTime receivedAt;
}
