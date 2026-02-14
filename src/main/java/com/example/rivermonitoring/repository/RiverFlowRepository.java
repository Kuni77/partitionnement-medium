package com.example.rivermonitoring.repository;

import com.example.rivermonitoring.entity.RiverFlow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface RiverFlowRepository extends JpaRepository<RiverFlow, Long> {

    List<RiverFlow> findByRiverCode(String riverCode);

    List<RiverFlow> findByRiverCodeAndMeasuredAtBetween(
            String riverCode, LocalDateTime from, LocalDateTime to);

    @Modifying
    @Query(value = """
            INSERT INTO river_flow (river_code, measured_at, flow_rate, received_at)
            VALUES (:riverCode, :measuredAt, :flowRate, NOW())
            ON CONFLICT (river_code, measured_at)
            DO UPDATE SET flow_rate = EXCLUDED.flow_rate, received_at = NOW()
            """, nativeQuery = true)
    void upsert(@Param("riverCode") String riverCode,
                @Param("measuredAt") LocalDateTime measuredAt,
                @Param("flowRate") Double flowRate);
}
