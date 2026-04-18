import 'dart:async';
import 'dart:convert';

import 'package:dharma_app/content/content_model.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/japa/japa_model.dart';
import 'package:dharma_app/japa/japa_repository.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class JapaController extends GetxController {
  JapaController({JapaRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<JapaRepository>()
                ? Get.find<JapaRepository>()
                : Get.put(JapaRepository(), permanent: true));

  final JapaRepository _repository;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final progress = Rxn<JapaProgress>();

  int? _activeMantraId;
  int _pendingIncrement = 0;
  bool _isFetchingRemote = false;

  bool get isReady => progress.value != null;
  int get count {
    final currentCount = progress.value?.currentCount;
    if (currentCount == null) return 0;
    return currentCount < 0 ? 0 : currentCount;
  }
  int get targetCount => progress.value?.targetCount ?? 108;
  int get chantsToday => progress.value?.chantsToday ?? count;
  int get malasCompleted => progress.value?.malasCompleted ?? 0;
  String get mantraName => progress.value?.mantraName ?? '';
  String? get audioPath => progress.value?.audioPath;
  int get pendingIncrement => _pendingIncrement;

  Future<void> ensureLoaded(MantraItem? mantra) async {
    final mantraId = mantra?.id;
    if (mantraId == null) return;
    final today = _todayKey();
    final current = progress.value;
    final alreadyLoadedForToday =
        _activeMantraId == mantraId &&
        current != null &&
        current.date == today;
    if (alreadyLoadedForToday) return;

    _activeMantraId = mantraId;
    isLoading.value = true;
    try {
      final cached = _readCachedProgress();
      if (cached != null && cached.date == today && cached.mantraId == mantraId) {
        progress.value = cached.copyWith(
          mantraName: cached.mantraName ?? mantra?.name,
          audioPath: cached.audioPath ?? mantra?.audioPath,
          audioFile: cached.audioFile ?? mantra?.audioFile,
        );
        _pendingIncrement = StorageService.getJapaPendingIncrement();
      } else {
        progress.value = _defaultProgress(mantra, today);
        _pendingIncrement = 0;
        await _cacheProgress();
        await _cachePendingIncrement();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFromServer(MantraItem? mantra) async {
    final mantraId = mantra?.id;
    if (mantraId == null) return;

    await ensureLoaded(mantra);
    if (_pendingIncrement > 0 || _isFetchingRemote) return;

    _isFetchingRemote = true;
    try {
      final model = await _repository.getJapaStatus(mantraId: mantraId);
      final remote = model.data?.japa;
      if (!model.success || remote == null || remote.date != _todayKey()) {
        return;
      }

      progress.value = remote.copyWith(
        mantraName: remote.mantraName ?? mantra?.name,
        audioPath: remote.audioPath ?? mantra?.audioPath,
        audioFile: remote.audioFile ?? mantra?.audioFile,
        malaSize: remote.malaSize ?? remote.targetCount ?? 108,
      );
      await _cacheProgress();
    } on TimeoutException {
      ToastUtils.show('Japa data sync timed out. Showing saved count.');
    } catch (_) {
      // Keep local cached progress if remote sync fails.
    } finally {
      _isFetchingRemote = false;
    }
  }

  Future<void> incrementCount(MantraItem? mantra) async {
    await ensureLoaded(mantra);
    final current = progress.value;
    if (current == null) return;

    final currentCount = current.currentCount ?? 0;
    final updatedChants = (current.chantsToday ?? current.currentCount ?? 0) + 1;
    final malaSize = current.malaSize ?? current.targetCount ?? 108;
    final updatedCount = currentCount >= malaSize ? 1 : currentCount + 1;

    progress.value = current.copyWith(
      currentCount: updatedCount,
      chantsToday: updatedChants,
      malasCompleted: updatedChants ~/ malaSize,
    );
    _pendingIncrement += 1;
    await _cacheProgress();
    await _cachePendingIncrement();
  }

  Future<void> saveNow() async {
    final current = progress.value;
    final mantraId = current?.mantraId;
    if (current == null || mantraId == null || _pendingIncrement <= 0) return;
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final model = await _repository.saveJapaProgress(
        mantraId: mantraId,
        incrementBy: _pendingIncrement,
        currentCount: current.currentCount,
        targetCount: current.targetCount ?? 108,
      );
      final remote = model.data?.japa;
      if (model.success && remote != null) {
        progress.value = remote.copyWith(
          mantraName: remote.mantraName ?? current.mantraName,
          audioPath: remote.audioPath ?? current.audioPath,
          audioFile: remote.audioFile ?? current.audioFile,
          malaSize: remote.malaSize ?? remote.targetCount ?? 108,
        );
        _pendingIncrement = 0;
        await _cacheProgress();
        await _cachePendingIncrement();
      }
    } on TimeoutException {
      ToastUtils.show('Saving japa progress is taking too long. It will retry later.');
    } catch (_) {
      // Preserve local pending count so the next save attempt can retry.
    } finally {
      isSaving.value = false;
    }
  }

  JapaProgress _defaultProgress(MantraItem? mantra, String today) {
    const defaultTarget = 108;
    return JapaProgress(
      date: today,
      mantraId: mantra?.id,
      mantraName: mantra?.name,
      audioFile: mantra?.audioFile,
      audioPath: mantra?.audioPath,
      currentCount: 0,
      targetCount: defaultTarget,
      malaSize: defaultTarget,
      chantsToday: 0,
      malasCompleted: 0,
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  JapaProgress? _readCachedProgress() {
    final raw = StorageService.getJapaProgress();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return JapaProgress.fromJson(decoded);
      }
      if (decoded is Map) {
        return JapaProgress.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return null;
  }

  Future<void> _cacheProgress() async {
    final current = progress.value;
    if (current == null) return;
    await StorageService.setJapaProgress(jsonEncode(current.toJson()));
  }

  Future<void> _cachePendingIncrement() async {
    await StorageService.setJapaPendingIncrement(_pendingIncrement);
  }

  @override
  void onClose() {
    unawaited(saveNow());
    super.onClose();
  }
}
