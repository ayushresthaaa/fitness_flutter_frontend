import '../base/base_provider.dart';
import '../../services/payment/subscription_service.dart';

class SubscriptionStatus {
  final String plan;
  final DateTime? planExpiresAt;
  final bool isActive;
  final bool isExpired;
  final int? daysLeft;

  SubscriptionStatus({
    required this.plan,
    this.planExpiresAt,
    required this.isActive,
    required this.isExpired,
    this.daysLeft,
  });

  bool get isPro => plan == 'pro';

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    return SubscriptionStatus(
      plan: map['plan'] ?? 'free',
      planExpiresAt: map['planExpiresAt'] != null
          ? DateTime.tryParse(map['planExpiresAt'])
          : null,
      isActive: map['isActive'] ?? false,
      isExpired: map['isExpired'] ?? false,
      daysLeft: map['daysLeft'],
    );
  }
}

class SubscriptionProvider extends BaseProvider {
  final SubscriptionService _service = SubscriptionService();

  SubscriptionStatus? _status;
  bool _isPaymentLoading = false;
  bool _initialLoad = true;

  SubscriptionStatus? get status => _status;
  bool get isPro => _status?.isPro ?? false;
  bool get isPaymentLoading => _isPaymentLoading;
  bool get initialLoad => _initialLoad;

  // Called on app start / profile screen load
  Future<void> fetchStatus() async {
    final result = await execute(() => _service.getStatus());
    _initialLoad = false;
    if (result != null) {
      _status = SubscriptionStatus.fromMap(result);
    }
    notifyListeners();
  }

  // Returns pidx + paymentUrl to open Khalti
  Future<Map<String, dynamic>?> initiate() async {
    _isPaymentLoading = true;
    notifyListeners();

    final result = await executeSilent(() => _service.initiate());

    _isPaymentLoading = false;
    notifyListeners();

    return result;
  }

  // Called after Khalti confirms payment
  // Returns status string: "completed" | "failed"
  Future<String?> verify(String pidx) async {
    _isPaymentLoading = true;
    notifyListeners();

    final result = await executeSilent(() => _service.verify(pidx));

    _isPaymentLoading = false;

    if (result != null && result['status'] == 'completed') {
      // Refresh status so UI reflects pro plan immediately
      await fetchStatus();
    } else {
      notifyListeners();
    }

    return result?['status'];
  }

  void reset() {
    _status = null;
    _isPaymentLoading = false;
    _initialLoad = true;
    clearError();
    notifyListeners();
  }
}
