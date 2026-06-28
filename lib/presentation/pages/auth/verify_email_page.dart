import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/auth/verify_firebase_token_usecase.dart';
import '../../../injection/injection_container.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feature_icon.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  static const _resendDelay = 60;

  int _timer = 60;
  bool _checking = false;
  bool _resending = false;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdown?.cancel();
    if (mounted) setState(() => _timer = _resendDelay);
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _timer <= 1) {
        timer.cancel();
        if (mounted) setState(() => _timer = 0);
        return;
      }
      setState(() => _timer--);
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.red : AppColors.green,
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser?.emailVerified != true) {
        _showMessage(
          'Email belum terverifikasi. Buka link di inbox atau folder spam.',
          error: true,
        );
        return;
      }

      // Paksa token baru agar claim email_verified sudah bernilai true.
      final firebaseToken = await refreshedUser!.getIdToken(true);
      if (firebaseToken == null) {
        throw Exception('Gagal mendapatkan token Firebase.');
      }

      await sl<VerifyFirebaseTokenUsecase>()(firebaseToken);
      if (mounted) context.go('/setup-2fa');
    } on AuthFailure catch (e) {
      _showMessage(e.message, error: true);
    } on ServerFailure catch (e) {
      _showMessage(e.message, error: true);
    } on NetworkFailure {
      _showMessage(
        'Backend tidak dapat dijangkau. Pastikan BE Emoney sedang berjalan dan alamat API benar.',
        error: true,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Gagal memeriksa verifikasi email.',
          error: true);
    } catch (e) {
      _showMessage(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }
      await user.sendEmailVerification();
      _startTimer();
      _showMessage('Link verifikasi baru telah dikirim.');
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'too-many-requests'
          ? 'Terlalu sering meminta email. Tunggu sebentar lalu coba lagi.'
          : (e.message ?? 'Gagal mengirim ulang email verifikasi.');
      _showMessage(message, error: true);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'email kamu';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                onPressed: () => context.go('/login'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(
                          DkgIcons.mail,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Verifikasi email',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Link verifikasi sudah dikirim ke\n',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14.5,
                          color: AppColors.slate500,
                          height: 1.55,
                        ),
                        children: [
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Buka email tersebut, tekan link verifikasi, lalu kembali ke aplikasi dan tekan tombol di bawah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        color: AppColors.slate500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Saya sudah verifikasi',
                      onPressed: _checking ? null : _checkVerification,
                      isLoading: _checking,
                    ),
                    const SizedBox(height: 16),
                    _timer > 0
                        ? Text(
                            'Kirim ulang dalam 00:${_timer.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13.5,
                              color: AppColors.slate400,
                            ),
                          )
                        : TextButton.icon(
                            onPressed: _resending ? null : _resend,
                            icon: _resending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    DkgIcons.refresh,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                            label: const Text(
                              'Kirim ulang link',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
