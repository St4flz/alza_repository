import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';

class GrandTotalCard extends StatefulWidget {
  final String amount;
  final String title;

  const GrandTotalCard({
    super.key,
    required this.amount,
    this.title = 'Gran total',
  });

  @override
  State<GrandTotalCard> createState() => _GrandTotalCardState();
}

class _GrandTotalCardState extends State<GrandTotalCard> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            widget.title,
            style: TextStyle(
              color: AppColors.negro.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.negro.solid,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.blanco.solid,
                  size: 20,
                ),
              ),
              Text(
                _obscureText ? '••••' : widget.amount,
                style: TextStyle(
                  color: AppColors.verde.solid,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: _obscureText ? 4.0 : 1.2,
                ),
              ),
              Text(
                '\$',
                style: TextStyle(
                  color: AppColors.blanco.solid,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
