// lib/screens/user/trainer_request/trainer_change_request_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common.dart';
import '../../../providers/trainer/trainer_request_provider.dart';
import 'widgets/active_request_card.dart';
import 'widgets/current_trainer_card.dart';
import 'widgets/past_request_card.dart';

class TrainerChangeRequestScreen extends StatefulWidget {
  const TrainerChangeRequestScreen({super.key});

  @override
  State<TrainerChangeRequestScreen> createState() =>
      _TrainerChangeRequestScreenState();
}

class _TrainerChangeRequestScreenState
    extends State<TrainerChangeRequestScreen> {
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainerRequestProvider>().init();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final provider = context.read<TrainerRequestProvider>();
    final success = await provider.submitRequest(
      reason: _reasonController.text.trim(),
    );

    if (!mounted) return;

    if (success && !provider.hasError) {
      _reasonController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request submitted successfully'),
          backgroundColor: kGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Something went wrong'),
          backgroundColor: kRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainerRequestProvider>();
    final trainer = provider.myTrainer;
    final activeRequest = provider.activeRequest;
    final pastRequests = provider.requests.where((r) => !r.isPending).toList();
    final hasTrainer = trainer != null;
    final canRequest = hasTrainer && activeRequest == null;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: const AppTopBar(title: 'My Trainer'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : RefreshIndicator(
              color: kPrimary,
              onRefresh: () => provider.init(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SectionLabel('Current Trainer'),
                  const SizedBox(height: 8),
                  CurrentTrainerCard(trainer: trainer),

                  if (activeRequest != null) ...[
                    const SizedBox(height: 16),
                    ActiveRequestCard(request: activeRequest),
                  ],

                  if (canRequest) ...[
                    const SizedBox(height: 16),
                    const SectionLabel('Request Trainer Change'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _reasonController,
                      hint: 'Why do you want to change trainer? (optional)',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Request Trainer Change',
                      onTap: _submitRequest,
                      isLoading: provider.isLoading,
                    ),
                  ],

                  if (pastRequests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const SectionLabel('Past Requests'),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pastRequests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          PastRequestTile(request: pastRequests[i]),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
