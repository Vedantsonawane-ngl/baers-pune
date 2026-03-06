import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/blood_request_api_model.dart';
import 'api_service.dart';

/// Global singleton store for live blood requests.
///
/// Screens subscribe with [ValueListenableBuilder] — no extra packages needed.
/// Polling is every 5 seconds so the feed stays near-real-time.
class RequestsStore {
  RequestsStore._();
  static final RequestsStore instance = RequestsStore._();

  /// All currently active requests from the backend.
  final ValueNotifier<List<BloodRequestApiModel>> requests = ValueNotifier(
    const [],
  );

  /// True while the very first fetch is running.
  final ValueNotifier<bool> loading = ValueNotifier(false);

  /// Non-null when the last fetch failed.
  final ValueNotifier<String?> error = ValueNotifier(null);

  Timer? _timer;

  // ── Start polling ─────────────────────────────────────────────────────

  void startPolling() {
    _fetch(); // immediate first load
    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  // ── Fetch from backend ────────────────────────────────────────────────

  Future<void> _fetch() async {
    if (requests.value.isEmpty) loading.value = true;
    try {
      final data = await ApiService.fetchRequests();
      requests.value = data;
      error.value = null;
    } catch (e) {
      error.value = 'Could not reach server';
    } finally {
      loading.value = false;
    }
  }

  /// Force-refresh immediately (e.g. after submitting a new request).
  Future<void> refresh() => _fetch();

  // ── Optimistically prepend a request (instant UI update) ─────────────

  void addOptimistic(BloodRequestApiModel req) {
    requests.value = [req, ...requests.value];
  }

  // ── Optimistically cancel ─────────────────────────────────────────────

  void cancelOptimistic(int id) {
    requests.value = requests.value.where((r) => r.id != id).toList();
  }
}
