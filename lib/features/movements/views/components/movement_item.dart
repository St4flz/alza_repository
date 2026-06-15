import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/features/movements/models/movement_model.dart';

class MovementItem extends StatelessWidget {
  final Movement movement;
  const MovementItem({super.key, required this.movement});

  String _formatCurrency(double amount) {
    final String str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    buffer.write(' \$');
    return buffer.toString();
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = movement.type == 'expense';
    final Color typeColor = isExpense ? Colors.redAccent : AppColors.verde.solid;
    final IconData typeIcon = isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final String sign = isExpense ? '-' : '+';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.blanco.solid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.negro.solid.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.12),
            radius: 20,
            child: Icon(
              typeIcon,
              color: typeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.title,
                  style: AppFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.negro.solid,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${movement.categoryName} • ${_formatDate(movement.createdAt)}',
                  style: AppFonts.montserrat(
                    fontSize: 12,
                    color: AppColors.negro.solid.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign ${_formatCurrency(movement.amount)}',
            style: AppFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}
