import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'alarm_sound.dart';

class LocalAppAudioService implements AppAudioService {
  LocalAppAudioService({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _completedSubscription = _player.onPlayerComplete.listen(
      (_) => _handlePlayerComplete(),
    );
  }

  final AudioPlayer _player;
  StreamSubscription<void>? _completedSubscription;
  void Function()? _onCompleted;
  bool _isDisposed = false;

  @override
  Future<void> playEffect(AppAudioEffect effect) {
    return _playAsset(effect.assetPath);
  }

  @override
  Future<void> previewAlarm(
    AlarmSound sound, {
    void Function()? onCompleted,
  }) {
    return _playAsset(sound.assetPath, onCompleted: onCompleted);
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) {
      return;
    }

    try {
      await _player.stop();
    } catch (error, stackTrace) {
      _reportError('detener el audio', error, stackTrace);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    unawaited(_completedSubscription?.cancel());
    try {
      await _player.dispose();
    } catch (error, stackTrace) {
      _reportError('liberar el reproductor de audio', error, stackTrace);
    }
  }

  Future<void> _playAsset(String assetPath, {void Function()? onCompleted}) async {
    if (_isDisposed) {
      return;
    }

    try {
      _onCompleted = onCompleted;
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (error, stackTrace) {
      _onCompleted = null;
      _reportError('reproducir el audio', error, stackTrace);
    }
  }

  void _handlePlayerComplete() {
    final onCompleted = _onCompleted;
    _onCompleted = null;
    onCompleted?.call();
  }

  void _reportError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('No fue posible $operation: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
