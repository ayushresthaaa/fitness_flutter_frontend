import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';
import '../../providers/payment/subscription_provider.dart';
import '../../widgets/common.dart';

class SubscriptionScreen extends StatefulWidget {
  static const routeName = '/subscription';

  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().fetchStatus();
    });
  }

  Future<void> _startPayment() async {
    final provider = context.read<SubscriptionProvider>();

    final result = await provider.initiate();
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to initiate payment'),
          ),
        );
      }
      return;
    }

    final pidx = result['pidx'] as String;

    if (!mounted) return;

    final payConfig = KhaltiPayConfig(
      publicKey: 'c022678dc644484daebba89b688110ec',
      pidx: pidx,
      environment: Environment.test,
    );

    final khalti = await Khalti.init(
      enableDebugging: true,
      payConfig: payConfig,
      onPaymentResult: (paymentResult, khalti) async {
        log('Subscription payment result: $paymentResult');
        await _verifyPayment(pidx, khalti);
      },
      onMessage:
          (
            khalti, {
            description,
            statusCode,
            event,
            needsPaymentConfirmation,
          }) async {
            log('Khalti message: $description');
            if (needsPaymentConfirmation == true) {
              await _verifyPayment(pidx, khalti);
            } else {
              khalti.close(context);
            }
          },
      onReturn: () {
        log('Returned to app from Khalti');
      },
    );

    if (mounted) {
      khalti.open(context);
    }
  }

  Future<void> _verifyPayment(String pidx, Khalti khalti) async {
    final provider = context.read<SubscriptionProvider>();
    final status = await provider.verify(pidx);

    if (!mounted) return;

    khalti.close(context);

    if (status == 'completed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pro plan activated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment could not be verified. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    final status = provider.status;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(title: 'Your Plan'),
      body: provider.isLoading || provider.initialLoad
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : status == null
          ? const Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load plan',
                subtitle: 'Pull down to retry',
              ),
            )
          : status.isPro
          ? _ProView(status: status)
          : const _FreeView(),
      bottomNavigationBar: _buildBottomBar(provider, status),
    );
  }

  Widget? _buildBottomBar(
    SubscriptionProvider provider,
    SubscriptionStatus? status,
  ) {
    if (status == null) return null;

    // Free user always sees upgrade button
    if (!status.isPro) {
      return BottomBar(
        child: PrimaryButton(
          text: 'Upgrade to Pro  —  Rs. 500 / month',
          isLoading: provider.isPaymentLoading,
          onTap: provider.isPaymentLoading ? null : _startPayment,
        ),
      );
    }

    // Pro user only sees renew button if expiring soon or already expired
    final shouldShowRenew =
        status.isExpired || (status.daysLeft != null && status.daysLeft! <= 7);

    if (shouldShowRenew) {
      return BottomBar(
        child: PrimaryButton(
          text: status.isExpired ? 'Renew Plan' : 'Renew Early  —  Rs. 500',
          isLoading: provider.isPaymentLoading,
          onTap: provider.isPaymentLoading ? null : _startPayment,
        ),
      );
    }

    return null;
  }
}

// ─────────────────────────────────────────────
// FREE USER VIEW
// ─────────────────────────────────────────────

class _FreeView extends StatelessWidget {
  const _FreeView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Unlock the full fitness experience',
                  style: TextStyle(fontSize: 13, color: kTextGrey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Plan comparison
          const SectionLabel('Compare Plans'),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free column
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Free',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rs. 0',
                        style: TextStyle(fontSize: 13, color: kTextGrey),
                      ),
                      SizedBox(height: 16),
                      _FeatureRow(label: 'Workouts', included: true),
                      _FeatureRow(label: 'Exercises', included: true),
                      _FeatureRow(label: 'Meal Log', included: true),
                      _FeatureRow(label: 'History', included: true),
                      _FeatureRow(label: 'AI Routine', included: false),
                      _FeatureRow(label: 'Trainer', included: false),
                      _FeatureRow(label: 'Insights', included: false),
                      _FeatureRow(label: 'Reminders', included: false),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Pro column
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pro',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kWhite,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rs. 500 / mo',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      SizedBox(height: 16),
                      _FeatureRow(
                        label: 'Workouts',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'Exercises',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'Meal Log',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'History',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'AI Routine',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'Trainer',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'Insights',
                        included: true,
                        isPro: true,
                      ),
                      _FeatureRow(
                        label: 'Reminders',
                        included: true,
                        isPro: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Payment note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Secure payment via Khalti',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Billed monthly. Cancel anytime.',
                  style: TextStyle(fontSize: 12, color: kTextGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Space for sticky bottom button
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRO USER VIEW
// ─────────────────────────────────────────────

class _ProView extends StatelessWidget {
  final SubscriptionStatus status;

  const _ProView({required this.status});

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon =
        !status.isExpired && status.daysLeft != null && status.daysLeft! <= 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pro Member',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kWhite,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You\'re all set',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enjoying the full fitness experience',
                  style: TextStyle(fontSize: 13, color: kTextGrey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Plan details
          const SectionLabel('Your Plan'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pro Plan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                    const Text(
                      'Rs. 500 / month',
                      style: TextStyle(fontSize: 13, color: kTextGrey),
                    ),
                  ],
                ),
                const Divider(color: kDivider, height: 24),
                _PlanDetailRow(
                  label: 'Status',
                  value: status.isExpired ? 'Expired' : 'Active',
                  valueColor: status.isExpired ? kRed : kGreen,
                ),
                const SizedBox(height: 10),
                _PlanDetailRow(
                  label: 'Expires',
                  value: _formatDate(status.planExpiresAt),
                ),
                const SizedBox(height: 10),
                _PlanDetailRow(
                  label: 'Days left',
                  value: status.isExpired
                      ? 'Expired'
                      : '${status.daysLeft ?? 0} days',
                  valueColor: isExpiringSoon ? const Color(0xFFF57C00) : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // What you have
          const SectionLabel('What You Have'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                _ProFeatureItem(
                  title: 'AI-Generated Routines',
                  subtitle: 'Personalized to your goals and fitness level',
                ),
                Divider(color: kDivider, height: 24),
                _ProFeatureItem(
                  title: 'Personal Trainer',
                  subtitle: 'Assigned automatically to guide your progress',
                ),
                Divider(color: kDivider, height: 24),
                _ProFeatureItem(
                  title: 'Meal Insights',
                  subtitle: 'Weekly nutrition reports and macro tracking',
                ),
                Divider(color: kDivider, height: 24),
                _ProFeatureItem(
                  title: 'Smart Reminders',
                  subtitle: 'Workout and meal alerts on your schedule',
                ),
              ],
            ),
          ),

          // Warning card — expiring soon
          if (isExpiringSoon || status.isExpired) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.isExpired
                        ? 'Your plan has expired'
                        : 'Your plan expires soon',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D4C00),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.isExpired
                        ? 'Renew now to restore access to Pro features.'
                        : 'Renew now to avoid losing access to Pro features.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8D6E00),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Space for sticky bottom button when shown
          if (isExpiringSoon || status.isExpired)
            const SizedBox(height: 100)
          else
            const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool included;
  final bool isPro;

  const _FeatureRow({
    required this.label,
    required this.included,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            included ? Icons.check : Icons.close,
            size: 14,
            color: isPro
                ? (included ? kWhite : Colors.white38)
                : (included ? kGreen : kTextHint),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isPro
                  ? (included ? kWhite : Colors.white54)
                  : (included ? kTextDark : kTextGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PlanDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: kTextGrey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? kTextDark,
          ),
        ),
      ],
    );
  }
}

class _ProFeatureItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ProFeatureItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check, size: 16, color: kGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: kTextGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
