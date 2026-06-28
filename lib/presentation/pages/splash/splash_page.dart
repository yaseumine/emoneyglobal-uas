import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/deeplink_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final pending = DeeplinkService.consumePending();
          if (pending != null) {
            context.go('/pay', extra: pending);
          } else {
            context.go('/home');
          }
        } else if (state is AuthUnauthenticated) {
          // Stay on splash to show welcome
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _motion,
          builder: (context, _) {
            final drift = _motion.value;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + drift * 0.25, -1),
                  end: Alignment(1 - drift * 0.2, 1),
                  colors: const [
                    Color(0xFFFF9CCB),
                    AppColors.primary,
                    Color(0xFF9B165F),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -120 + (drift * 22),
                  right: -92 + (drift * 18),
                  child: const _GlowCircle(size: 320, alpha: 0.12),
                ),
                Positioned(
                  bottom: 116 - (drift * 24),
                  left: -96 + (drift * 18),
                  child: const _GlowCircle(size: 220, alpha: 0.09),
                ),
                Positioned(
                  top: 130 + (drift * 18),
                  left: 28 + (drift * 10),
                  child: const _SparkleDot(size: 12),
                ),
                Positioned(
                  right: 38,
                  bottom: 220 - (drift * 18),
                  child: const _SparkleDot(size: 8),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(),
                      const AppLogo(size: 92, light: true, animated: true),
                      const SizedBox(height: 26),
                      const Text(
                        'Dompet Stardew',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bayar, transfer, dan kelola uang kuliah\ndalam satu aplikasi yang aman.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          AppButton(
                            label: 'Buat Akun Baru',
                            variant: AppButtonVariant.white,
                            onPressed: () => context.push('/register'),
                          ),
                          const SizedBox(height: 11),
                          AppButton(
                            label: 'Masuk ke Akun',
                            variant: AppButtonVariant.outlineWhite,
                            onPressed: () => context.push('/login'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double alpha;

  const _GlowCircle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _SparkleDot extends StatelessWidget {
  final double size;

  const _SparkleDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.74),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.42),
            blurRadius: 18,
            spreadRadius: 3,
          ),
        ],
      ),
    );
  }
}
