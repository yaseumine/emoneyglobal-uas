import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/deeplink_callback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../../injection/injection_container.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/code_input.dart';
import '../../widgets/feature_icon.dart';
import '../../widgets/pin_pad.dart';

enum _PaymentStep { pin, otp }

class PinPage extends StatefulWidget {
  final Map<String, dynamic> flowData;

  const PinPage({super.key, required this.flowData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  _PaymentStep _step = _PaymentStep.pin;
  String _pin = '';
  String _otpCode = '';
  String _twoFaMethod = AppConstants.twoFaTotp;
  bool _busy = false;
  bool _otpError = false;
  int _resendTimer = AppConstants.otpResendSeconds;
  Timer? _countdown;

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _onPinComplete(String pin) {
    setState(() {
      _pin = pin;
      _busy = true;
    });

    if (_kind == AppConstants.txnTopup) {
      context.read<PaymentBloc>().add(
            PaymentTopupRequested(
              (widget.flowData['amount'] as num).toDouble(),
            ),
          );
    } else {
      _prepareOtpStep();
    }
  }

  Future<void> _prepareOtpStep() async {
    final method = await sl<SecureStorageDatasource>().get2faMethod();
    if (!mounted) return;

    setState(() {
      _twoFaMethod = method ?? AppConstants.twoFaTotp;
      _busy = false;
      _step = _PaymentStep.otp;
    });

    if (_twoFaMethod == AppConstants.twoFaSmtp) {
      context.read<OtpBloc>().add(OtpSendEmail());
      _startResendTimer();
    } else if (_twoFaMethod == AppConstants.twoFaNotif) {
      context.read<OtpBloc>().add(OtpSendFirebase());
      _startResendTimer();
    }
  }

  void _startResendTimer() {
    _countdown?.cancel();
    setState(() => _resendTimer = AppConstants.otpResendSeconds);
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendTimer <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendTimer = 0);
        return;
      }
      setState(() => _resendTimer--);
    });
  }

  void _resendOtp() {
    if (_twoFaMethod == AppConstants.twoFaSmtp) {
      context.read<OtpBloc>().add(OtpSendEmail());
    } else if (_twoFaMethod == AppConstants.twoFaNotif) {
      context.read<OtpBloc>().add(OtpSendFirebase());
    }
    _startResendTimer();
  }

  String get _kind => widget.flowData['kind'] as String? ?? '';

  String get _otpType {
    switch (_twoFaMethod) {
      case AppConstants.twoFaSmtp:
        return AppConstants.otpTypeEmail;
      case AppConstants.twoFaNotif:
        return AppConstants.otpTypeFirebase;
      default:
        return AppConstants.otpTypeTotp;
    }
  }

  String get _description {
    if (_kind == AppConstants.txnTransfer) {
      return widget.flowData['note'] as String? ?? 'Transfer';
    }
    return widget.flowData['description'] as String? ?? 'Pembayaran';
  }

  String? get _callbackUrl {
    if (_kind != AppConstants.txnDeeplink) return null;
    final value = widget.flowData['callbackUrl'] as String?;
    return value?.isNotEmpty == true ? value : null;
  }

  String? get _callbackReference => widget.flowData['reference'] as String?;

  void _onOtpChanged(String value) {
    setState(() {
      _otpCode = value;
      _otpError = false;
    });
    if (value.length == AppConstants.otpLength) {
      setState(() => _busy = true);
      context.read<PaymentBloc>().add(
            PaymentTransferRequested(
              amount: (widget.flowData['amount'] as num).toDouble(),
              description: _description,
              otpCode: value,
              otpType: _otpType,
            ),
          );
    }
  }

  void _sendCallback(String status, {int? transactionId}) {
    final callbackUrl = _callbackUrl;
    if (callbackUrl == null) return;

    if (status == 'success' && transactionId != null) {
      DeeplinkCallbackService.notifySuccess(
        callbackUrl: callbackUrl,
        reference: _callbackReference,
        transactionId: transactionId,
      );
    } else if (status == 'cancelled') {
      DeeplinkCallbackService.notifyCancelled(
        callbackUrl: callbackUrl,
        reference: _callbackReference,
      );
    } else {
      DeeplinkCallbackService.notifyFailed(
        callbackUrl: callbackUrl,
        reference: _callbackReference,
        errorMessage: status,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentBloc, PaymentState>(
          listener: _onPaymentState,
        ),
        BlocListener<OtpBloc, OtpState>(
          listener: (context, state) {
            if (state is OtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.ink,
                  ),
                  onPressed: _close,
                ),
              ),
              if (_busy)
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 18),
                      Text(
                        'Memproses transaksi…',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_step == _PaymentStep.pin)
                Expanded(child: _buildPinStep())
              else
                Expanded(child: _buildOtpStep()),
            ],
          ),
        ),
      ),
    );
  }

  void _onPaymentState(BuildContext context, PaymentState state) {
    if (state is PaymentTransferSuccess) {
      final result = state.result;
      _sendCallback('success', transactionId: result.transactionId);
      context.go('/success', extra: {
        'title': 'Pembayaran berhasil',
        'subtitle': result.description,
        'amount': result.amount,
        'lines': [
          ['Jumlah', CurrencyFormatter.format(result.amount)],
          ['Saldo setelah', CurrencyFormatter.format(result.balanceAfter)],
          ['Ref', 'DKG${result.transactionId}'],
        ],
      });
    } else if (state is PaymentTopupSuccess) {
      context.go('/success', extra: {
        'title': 'Top up berhasil',
        'subtitle': 'Saldo kamu bertambah',
        'amount': state.amount,
        'lines': [
          ['Jumlah', CurrencyFormatter.format(state.amount)],
          ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
        ],
      });
    } else if (state is PaymentInvalidOtp) {
      setState(() {
        _busy = false;
        _otpError = true;
        _otpCode = '';
      });
    } else if (state is PaymentInsufficientBalance) {
      setState(() => _busy = false);
      _sendCallback('insufficient_balance');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo tidak cukup. Saldo saat ini '
            '${CurrencyFormatter.format(state.balance)}.',
          ),
          backgroundColor: AppColors.red,
        ),
      );
    } else if (state is PaymentError) {
      setState(() => _busy = false);
      _sendCallback('payment_error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _close() {
    if (_step == _PaymentStep.otp && !_busy) {
      _countdown?.cancel();
      setState(() {
        _step = _PaymentStep.pin;
        _pin = '';
        _otpCode = '';
      });
      return;
    }
    _sendCallback('cancelled');
    context.go('/home');
  }

  Widget _buildPinStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        children: [
          const FeatureIcon(
            icon: Icons.lock_outline_rounded,
            tone: 'blue',
            size: 64,
            iconSize: 28,
          ),
          const SizedBox(height: 16),
          const Text(
            'Masukkan PIN',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Masukkan 6 digit PIN keamanan kamu',
            style: TextStyle(color: AppColors.slate500),
          ),
          const Spacer(),
          PinPad(
            value: _pin,
            onChanged: (value) => setState(() => _pin = value),
            onComplete: _onPinComplete,
          ),
          const SizedBox(height: 18),
          const Text('Lupa PIN? Reset'),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    final header = _otpHeader;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      child: Column(
        children: [
          FeatureIcon(
            icon: header.icon,
            tone: header.tone,
            size: 74,
            iconSize: 36,
          ),
          const SizedBox(height: 18),
          Text(
            header.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            header.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate500, height: 1.5),
          ),
          const SizedBox(height: 28),
          CodeInput(
            value: _otpCode,
            onChanged: _onOtpChanged,
            hasError: _otpError,
          ),
          if (_otpError) ...[
            const SizedBox(height: 12),
            const Text(
              'Kode OTP salah, silakan coba lagi',
              style: TextStyle(color: AppColors.red),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Total ${CurrencyFormatter.format((widget.flowData['amount'] as num).toDouble())}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          if (_twoFaMethod != AppConstants.twoFaTotp)
            _resendTimer > 0
                ? Text(
                    'Kirim ulang dalam 00:'
                    '${_resendTimer.toString().padLeft(2, '0')}',
                  )
                : TextButton.icon(
                    onPressed: _resendOtp,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Kirim ulang kode'),
                  ),
        ],
      ),
    );
  }

  ({IconData icon, String tone, String title, String subtitle}) get _otpHeader {
    switch (_twoFaMethod) {
      case AppConstants.twoFaSmtp:
        return (
          icon: DkgIcons.mail,
          tone: 'blue',
          title: 'Masukkan Kode OTP Email',
          subtitle: 'Kode 6 digit telah dikirim ke email kamu.',
        );
      case AppConstants.twoFaNotif:
        return (
          icon: Icons.notifications_outlined,
          tone: 'green',
          title: 'Masukkan Kode OTP',
          subtitle: 'Kode telah dikirim ke notifikasi perangkat kamu.',
        );
      default:
        return (
          icon: DkgIcons.smartphone,
          tone: 'violet',
          title: 'Masukkan Kode Authenticator',
          subtitle: 'Masukkan kode aktif dari aplikasi authenticator.',
        );
    }
  }
}
