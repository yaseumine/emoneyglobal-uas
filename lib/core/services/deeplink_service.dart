import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

@immutable
class DeeplinkPaymentData {
  final String merchantId;
  final String merchantName;
  final double amount;
  final String description;
  final String? reference;
  final String? callbackUrl;

  const DeeplinkPaymentData({
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.description,
    this.reference,
    this.callbackUrl,
  });

  factory DeeplinkPaymentData.fromUri(Uri uri) {
    final query = uri.queryParameters;
    final merchantId = query['merchant_id'];
    final merchantName = query['merchant_name'];
    final amountText = query['amount'];

    if (merchantId == null || merchantId.trim().isEmpty) {
      throw const FormatException(
        'Link pembayaran tidak valid: merchant_id tidak ditemukan.',
      );
    }
    if (merchantName == null || merchantName.trim().isEmpty) {
      throw const FormatException(
        'Link pembayaran tidak valid: merchant_name tidak ditemukan.',
      );
    }
    if (amountText == null || amountText.trim().isEmpty) {
      throw const FormatException(
        'Link pembayaran tidak valid: amount tidak ditemukan.',
      );
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      throw const FormatException(
        'Link pembayaran tidak valid: amount harus berupa angka > 0.',
      );
    }

    return DeeplinkPaymentData(
      merchantId: merchantId,
      merchantName: merchantName,
      amount: amount,
      description: query['description']?.trim().isNotEmpty == true
          ? query['description']!.trim()
          : 'Pembayaran ke $merchantName',
      reference: query['reference'],
      callbackUrl: query['callback'],
    );
  }
}

class DeeplinkService {
  final GoRouter _router;
  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  static Object? _pendingPayload;

  DeeplinkService(this._router) : _appLinks = AppLinks();

  static Object? consumePending() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    return payload;
  }

  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && _isPaymentLink(initialUri)) {
        _storePending(initialUri);
      }
    } catch (error) {
      debugPrint('[DeeplinkService] initial link error: $error');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleInAppUri,
      onError: (Object error) {
        debugPrint('[DeeplinkService] stream error: $error');
      },
    );
  }

  void _storePending(Uri uri) {
    try {
      _pendingPayload = DeeplinkPaymentData.fromUri(uri);
    } on FormatException catch (error) {
      _pendingPayload = error.message;
    }
  }

  void _handleInAppUri(Uri uri) {
    if (!_isPaymentLink(uri)) return;

    Object payload;
    try {
      payload = DeeplinkPaymentData.fromUri(uri);
    } on FormatException catch (error) {
      payload = error.message;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router.go('/pay', extra: payload);
    });
  }

  bool _isPaymentLink(Uri uri) {
    if (uri.scheme == 'dompetkampus' && uri.host == 'pay') return true;
    return uri.scheme == 'https' &&
        uri.host == 'dompetkampus.app' &&
        uri.path.startsWith('/pay');
  }

  void dispose() => _subscription?.cancel();
}
