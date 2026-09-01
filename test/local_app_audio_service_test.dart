import 'dart:async';

import 'package:atomic_task/core/audio/alarm_sound.dart';
import 'package:atomic_task/core/audio/local_app_audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (_) async => null,
  );
  messenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (_) async => null,
  );
  _mockEventChannel('xyz.luan/audioplayers.global/events');
  _mockEventChannel('xyz.luan/audioplayers/events/test-player');

  test('previews every alarm and stops the previous playback first', () async {
    final player = _FakeAudioPlayer();
    final service = LocalAppAudioService(player: player);
    addTearDown(service.dispose);

    for (final sound in AlarmSound.values) {
      await service.previewAlarm(sound);
    }

    expect(player.stopCalls, AlarmSound.values.length);
    expect(
      player.playedAssets,
      AlarmSound.values.map((sound) => sound.assetPath).toList(),
    );
  });

  test('swallows playback errors so audio does not block the app', () async {
    final player = _FakeAudioPlayer(throwsOnPlay: true);
    final service = LocalAppAudioService(player: player);
    addTearDown(service.dispose);

    await expectLater(
      service.playEffect(AppAudioEffect.taskCreated),
      completes,
    );
    expect(player.stopCalls, 1);
    expect(player.disposeCalls, 0);
  });

  test('invokes the completion callback when a preview ends', () async {
    final player = _CompletableAudioPlayer();
    final service = LocalAppAudioService(player: player);
    addTearDown(service.dispose);
    var completed = 0;

    await service.previewAlarm(
      AlarmSound.amanecerCosmico,
      onCompleted: () => completed += 1,
    );
    expect(completed, 0);

    player.completions.add(null);
    await pumpEventQueue();
    expect(completed, 1);

    player.completions.add(null);
    await pumpEventQueue();
    expect(completed, 1, reason: 'the callback must be consumed once');
  });

  test('a played effect discards a pending preview callback', () async {
    final player = _CompletableAudioPlayer();
    final service = LocalAppAudioService(player: player);
    addTearDown(service.dispose);
    var completed = 0;

    await service.previewAlarm(
      AlarmSound.secuenciaDigital,
      onCompleted: () => completed += 1,
    );
    await service.playEffect(AppAudioEffect.taskCreated);

    player.completions.add(null);
    await pumpEventQueue();
    expect(completed, 0);
  });
}

class _CompletableAudioPlayer extends _FakeAudioPlayer {
  _CompletableAudioPlayer() : super();

  final StreamController<void> completions = StreamController.broadcast();

  @override
  Stream<void> get onPlayerComplete => completions.stream;
}

class _FakeAudioPlayer extends AudioPlayer {
  _FakeAudioPlayer({this.throwsOnPlay = false})
    : super(playerId: 'test-player');

  final bool throwsOnPlay;
  final List<String> playedAssets = [];
  var stopCalls = 0;
  var disposeCalls = 0;

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    if (throwsOnPlay) {
      throw StateError('test playback error');
    }
    playedAssets.add((source as AssetSource).path);
  }

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
  }
}

void _mockEventChannel(String channelName) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(channelName, (message) async {
        final call = const StandardMethodCodec().decodeMethodCall(message);
        return switch (call.method) {
          'listen' ||
          'cancel' => const StandardMethodCodec().encodeSuccessEnvelope(null),
          _ => throw StateError(
            'Unexpected event channel call: ${call.method}',
          ),
        };
      });
}
