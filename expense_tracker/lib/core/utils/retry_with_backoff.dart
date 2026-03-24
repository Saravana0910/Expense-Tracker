import 'package:flutter/foundation.dart';

/// Retry utility with exponential backoff for handling transient failures
class RetryHelper {
  /// Executes a future with exponential backoff retry logic
  /// 
  /// Parameters:
  /// - [operation]: The async operation to retry
  /// - [maxRetries]: Maximum number of retry attempts (default: 3)
  /// - [initialDelayMs]: Initial delay in milliseconds before first retry (default: 100)
  /// - [maxDelayMs]: Maximum delay in milliseconds between retries (default: 5000)
  /// - [backoffMultiplier]: Multiplier for exponential backoff (default: 2.0)
  /// - [onRetry]: Optional callback when retry occurs
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    int initialDelayMs = 100,
    int maxDelayMs = 5000,
    double backoffMultiplier = 2.0,
    void Function(int attempt, Duration delay, dynamic error)? onRetry,
  }) async {
    int attempt = 0;
    int delayMs = initialDelayMs;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        // Check if error is retriable (transient)
        if (!_isRetriableError(e) || attempt > maxRetries) {
          rethrow;
        }

        // Calculate delay with exponential backoff
        final delayDuration = Duration(milliseconds: delayMs);
        
        debugPrint(
          'Retry attempt $attempt/$maxRetries after ${delayDuration.inMilliseconds}ms '
          'due to: $e',
        );

        // Call onRetry callback if provided
        onRetry?.call(attempt, delayDuration, e);

        // Wait before retrying
        await Future.delayed(delayDuration);

        // Calculate next delay (with jitter to avoid thundering herd)
        delayMs = ((delayMs * backoffMultiplier).toInt())
            .clamp(initialDelayMs, maxDelayMs);
      }
    }
  }

  /// Check if an error is retriable (transient)
  static bool _isRetriableError(dynamic error) {
    final errorString = error.toString();

    // Firebase/Firestore transient errors
    if (errorString.contains('unavailable') ||
        errorString.contains('deadline-exceeded') ||
        errorString.contains('temporary') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('UNAVAILABLE') ||
        errorString.contains('DEADLINE_EXCEEDED') ||
        errorString.contains('INTERNAL')) {
      return true;
    }

    // Network errors
    if (errorString.contains('SocketException') ||
        errorString.contains('HandshakeException') ||
        errorString.contains('TimeoutException')) {
      return true;
    }

    return false;
  }
}
