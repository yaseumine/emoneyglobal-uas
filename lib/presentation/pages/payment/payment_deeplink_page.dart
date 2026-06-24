import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/deeplink_callback_service.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';

class PaymentDeeplinkPage extends StatelessWidget {
  final Object? data;

  const PaymentDeeplinkPage({super.key, this.data});

  void _cancel(BuildContext context, DeeplinkPaymentData payload) {
    final callbackUrl = payload.callbackUrl;
    if (callbackUrl != null && callbackUrl.isNotEmpty) {
      DeeplinkCallbackService.notifyCancelled(
        callbackUrl: callbackUrl,
        reference: payload.reference,
      );
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final payload = data;
    if (payload is! DeeplinkPaymentData) {
      return _ErrorView(
        message: payload is String
            ? payload
            : 'Link pembayaran tidak ditemukan atau tidak valid.',
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel(context, payload);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 6,
                16,
                14,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => _cancel(context, payload),
                  ),
                  const Expanded(
                    child: Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.storefront_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.shadowSoft,
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.format(payload.amount),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.shadowSoft,
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Merchant',
                            value: payload.merchantName,
                          ),
                          const Divider(height: 1, color: AppColors.line2),
                          _DetailRow(
                            label: 'Keterangan',
                            value: payload.description,
                          ),
                          if (payload.reference?.isNotEmpty == true) ...[
                            const Divider(height: 1, color: AppColors.line2),
                            _DetailRow(
                              label: 'Referensi',
                              value: payload.reference!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 1.8,
                        ),
                        boxShadow: AppColors.shadowSoft,
                      ),
                      child: const Row(
                        children: [
                          AppLogo(size: 40),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dompet Kampus Global',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  'Saldo · pembayaran instan',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.slate400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            DkgIcons.shieldCheck,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pembayaran akan diverifikasi dengan PIN dan metode 2FA akun kamu.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: AppButton(
                label: 'Bayar ${CurrencyFormatter.format(payload.amount)}',
                onPressed: () => context.go('/pin', extra: {
                  'kind': 'deeplink',
                  'amount': payload.amount,
                  'description': payload.description,
                  'merchantName': payload.merchantName,
                  'merchantId': payload.merchantId,
                  'reference': payload.reference,
                  'callbackUrl': payload.callbackUrl,
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.slate500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.link_off_rounded,
                size: 56,
                color: AppColors.red,
              ),
              const SizedBox(height: 18),
              const Text(
                'Link Pembayaran Tidak Valid',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.slate500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Kembali ke Beranda',
                fullWidth: false,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
