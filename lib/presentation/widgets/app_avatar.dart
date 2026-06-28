import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? bg;
  final String? imageUrl;

  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.bg,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final palette = [
      const Color(0xFFE83E8C),
      const Color(0xFFFF7AB6),
      const Color(0xFF1DAF86),
      const Color(0xFFFFA23F),
      const Color(0xFF8B5CF6),
      const Color(0xFFE9365E),
    ];
    final auto = palette[(name.isNotEmpty ? name.codeUnitAt(0) : 0) % palette.length];
    final initials = name
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? auto,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(imageUrl!, fit: BoxFit.cover)
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}
