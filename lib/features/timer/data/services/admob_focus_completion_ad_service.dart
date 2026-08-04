import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../domain/services/focus_completion_ad_service.dart';

class AdMobFocusCompletionAdService
    with WidgetsBindingObserver
    implements FocusCompletionAdService {
  AdMobFocusCompletionAdService() {
    if (_testAdUnitId != null) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  static const _androidTestAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

  Future<void>? _initialization;
  InterstitialAd? _interstitialAd;
  bool _sdkInitialized = false;
  bool _isLoading = false;
  bool _isDisposed = false;
  bool _showOnNextResume = false;

  @override
  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    if (_testAdUnitId == null || _isDisposed) {
      return;
    }

    try {
      await MobileAds.instance.initialize();
      if (_isDisposed) {
        return;
      }
      _sdkInitialized = true;
      await _loadAd();
    } catch (error, stackTrace) {
      _initialization = null;
      _reportError('inicializar AdMob', error, stackTrace);
    }
  }

  Future<void> _loadAd() async {
    final adUnitId = _testAdUnitId;
    if (adUnitId == null ||
        _isDisposed ||
        _isLoading ||
        _interstitialAd != null) {
      return;
    }

    _isLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _isLoading = false;
            if (_isDisposed) {
              _disposeAd(ad);
              return;
            }

            _interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _reportError(
              'cargar el anuncio de prueba',
              error,
              StackTrace.current,
            );
          },
        ),
      );
    } catch (error, stackTrace) {
      _isLoading = false;
      _reportError('cargar el anuncio de prueba', error, stackTrace);
    }
  }

  @override
  Future<void> showAfterFocusCompletion() async {
    if (_testAdUnitId == null || _isDisposed) {
      return;
    }

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      _showOnNextResume = true;
      return;
    }

    await _showIfReady();
  }

  Future<void> _showIfReady() async {
    if (!_sdkInitialized) {
      unawaited(initialize());
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(_loadAd());
      return;
    }

    _interstitialAd = null;
    var finalized = false;

    void finishAd(InterstitialAd finishedAd) {
      if (finalized) {
        return;
      }
      finalized = true;
      _disposeAd(finishedAd);
      if (!_isDisposed) {
        unawaited(_loadAd());
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: finishAd,
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        _reportError('mostrar el anuncio de prueba', error, StackTrace.current);
        finishAd(failedAd);
      },
    );

    try {
      await ad.show();
    } catch (error, stackTrace) {
      _reportError('mostrar el anuncio de prueba', error, stackTrace);
      finishAd(ad);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !_showOnNextResume ||
        _isDisposed) {
      return;
    }

    _showOnNextResume = false;
    unawaited(_showIfReady());
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _showOnNextResume = false;
    if (_testAdUnitId != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
    final ad = _interstitialAd;
    _interstitialAd = null;
    if (ad != null) {
      await ad.dispose();
    }
  }

  String? get _testAdUnitId {
    if (kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidTestAdUnitId,
      TargetPlatform.iOS => _iosTestAdUnitId,
      _ => null,
    };
  }

  void _disposeAd(InterstitialAd ad) {
    unawaited(
      ad.dispose().catchError((Object error, StackTrace stackTrace) {
        _reportError('liberar el anuncio de prueba', error, stackTrace);
      }),
    );
  }

  void _reportError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('No fue posible $operation: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
