import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool light;
  final bool withText;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 56,
    this.light = false,
    this.withText = false,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'PlusJakartaSans';

    Widget icon = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        gradient: light
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.78),
                ],
              )
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: light ? 0.22 : 0.28),
            blurRadius: size * 0.34,
            offset: Offset(0, size * 0.14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/images/uang.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: light ? Colors.white : AppColors.primary,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: size * 0.55,
              color: light ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );

    if (animated) {
      icon = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: icon,
      );
    }

    if (!withText) return icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dompet',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w800,
                color: light ? Colors.white : AppColors.ink,
                letterSpacing: 0,
                height: 1.05,
              ),
            ),
            Text(
              'STARDEW',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: size * 0.205,
                fontWeight: FontWeight.w700,
                color: light
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.primary,
                letterSpacing: 1.5,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
