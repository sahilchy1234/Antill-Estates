import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service for monitoring app performance metrics
class PerformanceMonitorService extends GetxService {
  static PerformanceMonitorService get instance => Get.find<PerformanceMonitorService>();
  
  final Map<String, DateTime> _startTimes = {};
  final Map<String, Duration> _durations = {};
  final RxMap<String, Duration> _metrics = <String, Duration>{}.obs;
  
  /// Start timing a performance metric
  void startTimer(String metricName) {
    _startTimes[metricName] = DateTime.now();
    if (kDebugMode) {
      print('⏱️ Started timing: $metricName');
    }
  }
  
  /// End timing a performance metric
  Duration? endTimer(String metricName) {
    final startTime = _startTimes[metricName];
    if (startTime == null) {
      print('⚠️ No start time found for metric: $metricName');
      return null;
    }
    
    final duration = DateTime.now().difference(startTime);
    _durations[metricName] = duration;
    _metrics[metricName] = duration;
    
    _startTimes.remove(metricName);
    
    if (kDebugMode) {
      print('✅ $metricName: ${duration.inMilliseconds}ms');
    }
    
    return duration;
  }
  
  /// Get all performance metrics
  Map<String, Duration> get metrics => Map.unmodifiable(_durations);
  
  /// Get a specific metric
  Duration? getMetric(String metricName) => _durations[metricName];
  
  /// Get startup performance summary
  Map<String, dynamic> getStartupSummary() {
    final criticalServices = getMetric('critical_services_init');
    final appStartup = getMetric('app_startup_total');
    final splashDisplay = getMetric('splash_display_time');
    
    return {
      'critical_services_init': criticalServices?.inMilliseconds,
      'app_startup_total': appStartup?.inMilliseconds,
      'splash_display_time': splashDisplay?.inMilliseconds,
      'total_metrics': _durations.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Log performance metrics to console
  void logMetrics() {
    if (kDebugMode) {
      print('\n📊 Performance Metrics:');
      print('=' * 40);
      
      _durations.forEach((metric, duration) {
        print('$metric: ${duration.inMilliseconds}ms');
      });
      
      print('=' * 40);
    }
  }
  
  /// Clear all metrics
  void clearMetrics() {
    _startTimes.clear();
    _durations.clear();
    _metrics.clear();
  }
  
  /// Check if startup time is within acceptable limits
  bool isStartupTimeAcceptable() {
    final totalStartup = getMetric('app_startup_total');
    if (totalStartup == null) return false;
    
    // Consider startup acceptable if under 3 seconds
    return totalStartup.inSeconds < 3;
  }
  
  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    
    final criticalServices = getMetric('critical_services_init');
    if (criticalServices != null && criticalServices.inSeconds > 2) {
      recommendations.add('Critical services initialization is slow (${criticalServices.inMilliseconds}ms). Consider lazy loading more services.');
    }
    
    final splashTime = getMetric('splash_display_time');
    if (splashTime != null && splashTime.inSeconds > 3) {
      recommendations.add('Splash screen display time is long (${splashTime.inMilliseconds}ms). Consider reducing initialization time.');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Performance looks good! No optimizations needed.');
    }
    
    return recommendations;
  }
}
