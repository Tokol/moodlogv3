import 'package:flutter/material.dart';

class CakeButton extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final bool isDisabled;
  VoidCallback onClick;
  CakeButton({
    required this.onClick,
    required this.title, required this.color, required this.icon, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: isDisabled
            ? null
            : onClick,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              offset: Offset(6, 6),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: Offset(-3, -3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
