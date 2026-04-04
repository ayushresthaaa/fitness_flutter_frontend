// lib/providers/trainer/trainer_request_provider.dart

// import 'package:flutter/material.dart';
import '../../models/trainer/trainer_request_model.dart';
import '../../services/trainer/trainer_request_service.dart';
import '../base/base_provider.dart';

class TrainerRequestProvider extends BaseProvider {
  final _service = TrainerRequestService();

  Map<String, dynamic>? _myTrainer;
  List<TrainerChangeRequest> _requests = [];
  TrainerChangeRequest? get activeRequest =>
      _requests.where((r) => r.isPending).firstOrNull;

  Map<String, dynamic>? get myTrainer => _myTrainer;
  List<TrainerChangeRequest> get requests => _requests;

  Future<void> loadMyTrainer() async {
    await execute(() async {
      _myTrainer = await _service.getMyTrainer();
    });
  }

  Future<void> loadMyRequests() async {
    await execute(() async {
      _requests = await _service.getMyRequests();
    });
  }

  Future<void> init() async {
    await Future.wait([loadMyTrainer(), loadMyRequests()]);
  }

  Future<bool> submitRequest({String? reason}) async {
    final result = await execute(() async {
      await _service.submitRequest(reason: reason);
      // reload everything fresh from backend
      await Future.wait([loadMyTrainer(), loadMyRequests()]);
    });
    return result != null;
  }
}
