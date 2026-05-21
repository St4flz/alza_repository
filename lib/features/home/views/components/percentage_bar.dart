import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';

class PercentageBar extends StatelessWidget {
  final List<Wallet> wallets;

  const PercentageBar({super.key, required this.wallets});

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return const SizedBox.shrink();
    }

    final double totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);

    // Calculate percentages
    final List<Map<String, dynamic>> segments = [];
    if (totalBalance == 0) {
      // Equal distribution if total is 0
      final double equalPct = 100.0 / wallets.length;
      for (int i = 0; i < wallets.length; i++) {
        segments.add({
          'wallet': wallets[i],
          'percentage': equalPct,
        });
      }
    } else {
      for (final wallet in wallets) {
        final double pct = (wallet.balance / totalBalance) * 100.0;
        segments.add({
          'wallet': wallet,
          'percentage': pct,
        });
      }
    }

    // Colors to match the screenshot (gradient from light grey-green to dark grey/black)
    final List<Color> segmentColors = [
      AppColors.verde.solid.withOpacity(0.3), // Light greyish green
      AppColors.negro.solid.withOpacity(0.55), // Dark grey
      AppColors.negro.solid, // Black
    ];

    // Filter out 0% segments to avoid layout issues, and ensure we have at least some flex
    final activeSegments = segments.where((s) => s['percentage'] > 0).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 16,
              color: Colors.transparent,
              child: Row(
                children: List.generate(activeSegments.length, (index) {
                final segment = activeSegments[index];
                final double pct = segment['percentage'];
                final int flexValue = (pct * 10).round().clamp(1, 1000);

                // Pick a color: cyclically or based on index matching the screenshot
                final Color color = index < segmentColors.length
                    ? segmentColors[index]
                    : AppColors.negro.solid;

                return Expanded(
                  flex: flexValue,
                  child: Container(
                    color: color,
                    alignment: Alignment.center,
                    child: Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: AppFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: index == 0
                            ? AppColors.negro.solid.withOpacity(0.6)
                            : AppColors.blanco.solid.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
