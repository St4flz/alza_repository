import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class WalletEditSheet extends StatefulWidget {
  final IconData initialIcon;
  final Color initialColor;
  final Function(IconData, Color) onSelected;

  const WalletEditSheet({
    super.key,
    required this.initialIcon,
    required this.initialColor,
    required this.onSelected,
  });

  @override
  State<WalletEditSheet> createState() => _WalletEditSheetState();
}

class _WalletEditSheetState extends State<WalletEditSheet> {
  late IconData _selectedIcon;
  late Color _selectedColor;

  final List<IconData> _icons = [
    Icons.badge_outlined,
    Icons.savings_outlined,
    Icons.menu_book_rounded,
    Icons.account_balance_wallet_outlined,
    Icons.credit_card_rounded,
    Icons.account_balance_rounded,
    Icons.attach_money_rounded,
    Icons.storefront_rounded,
  ];

  final List<Color> _colors = [
    const Color(0xFF00D764), // Verde App
    const Color(0xFF3B82F6), // Azul
    const Color(0xFF8B5CF6), // Violeta
    const Color(0xFFF97316), // Naranja
    const Color(0xFFEC4899), // Rosa
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFEAB308), // Amarillo/Amber
    const Color(0xFFEF4444), // Rojo
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.initialIcon;
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanco.solid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(28.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.negro.solid.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Personalizar billetera',
              style: AppFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.negro.solid,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona un ícono',
              style: AppFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.negro.solid.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            // Icons Grid
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = _selectedIcon == icon;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.15)
                            : AppColors.negro.solid.withOpacity(0.04),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : AppColors.negro.solid,
                        size: 26,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Selecciona un color',
              style: AppFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.negro.solid.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            // Colors list
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColor == color;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.negro.solid, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Confirm button
            ElevatedButton(
              onPressed: () {
                widget.onSelected(_selectedIcon, _selectedColor);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.negro.solid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Aplicar cambios',
                style: AppFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blanco.solid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
