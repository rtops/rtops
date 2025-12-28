package com.rtops.objectdetector

import java.util.concurrent.ConcurrentHashMap

data class ObjectStats(
    val label: String,
    var count: Int = 0,
    var lastSeen: Long = System.currentTimeMillis()
)

class ObjectTracker {
    private val detectedObjects = ConcurrentHashMap<String, ObjectStats>()
    private val detectionHistory = mutableListOf<DetectionEvent>()
    private val maxHistorySize = 1000

    data class DetectionEvent(
        val label: String,
        val timestamp: Long,
        val confidence: Float
    )

    fun trackObject(label: String, confidence: Float) {
        val now = System.currentTimeMillis()

        synchronized(detectedObjects) {
            val stats = detectedObjects.getOrPut(label) {
                ObjectStats(label, 0, now)
            }

            // Only count if not seen in last 2 seconds (to avoid counting same object multiple times)
            if (now - stats.lastSeen > 2000) {
                stats.count++
            }
            stats.lastSeen = now
        }

        synchronized(detectionHistory) {
            detectionHistory.add(DetectionEvent(label, now, confidence))

            // Keep history limited
            if (detectionHistory.size > maxHistorySize) {
                detectionHistory.removeAt(0)
            }
        }
    }

    fun getObjectStats(): List<ObjectStats> {
        return detectedObjects.values
            .sortedByDescending { it.count }
            .toList()
    }

    fun getPatterns(): Map<String, Int> {
        // Analyze patterns in detection history
        val patterns = mutableMapOf<String, Int>()

        synchronized(detectionHistory) {
            detectionHistory
                .groupBy { it.label }
                .forEach { (label, events) ->
                    patterns[label] = events.size
                }
        }

        return patterns.toSortedMap()
    }

    fun clear() {
        detectedObjects.clear()
        detectionHistory.clear()
    }

    fun getTotalDetections(): Int {
        return detectedObjects.values.sumOf { it.count }
    }

    fun getMostCommonObject(): String? {
        return detectedObjects.values
            .maxByOrNull { it.count }
            ?.label
    }
}
