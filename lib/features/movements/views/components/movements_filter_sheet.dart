import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/features/movements/providers/movements_provider.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';

class MovementsFilter {
  final String? type;
  final String? walletId;
  final String? categoryId;
  final String? tagId;

  MovementsFilter({
    this.type,
    this.walletId,
    this.categoryId,
    this.tagId,
  });

  MovementsFilter copyWith({
    String? type,
    String? walletId,
    String? categoryId,
    String? tagId,
    bool clearType = false,
    bool clearWalletId = false,
    bool clearCategoryId = false,
    bool clearTagId = false,
  }) {
    return MovementsFilter(
      type: clearType ? null : (type ?? this.type),
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      tagId: clearTagId ? null : (tagId ?? this.tagId),
    );
  }
}

class MovementsFilterSheet extends StatefulWidget {
  final MovementsFilter initialFilter;

  const MovementsFilterSheet({
    super.key,
    required this.initialFilter,
  });

  @override
  State<MovementsFilterSheet> createState() => _MovementsFilterSheetState();
}

class _MovementsFilterSheetState extends State<MovementsFilterSheet> {
  late MovementsFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final walletsProvider = Provider.of<WalletsProvider>(context);
    final movementsProvider = Provider.of<MovementsProvider>(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.blanco.solid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtros',
            style: AppFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.negro.solid,
            ),
          ),
          const SizedBox(height: 24),
          
          // Tipo
          Text('Tipo de movimiento', style: _labelStyle()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'Todos',
                isSelected: _currentFilter.type == null,
                onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(clearType: true)),
              ),
              _buildFilterChip(
                label: 'Ingresos',
                isSelected: _currentFilter.type == 'income',
                onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(type: 'income')),
              ),
              _buildFilterChip(
                label: 'Gastos',
                isSelected: _currentFilter.type == 'expense',
                onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(type: 'expense')),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Billetera
          Text('Billetera', style: _labelStyle()),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todas',
                  isSelected: _currentFilter.walletId == null,
                  onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(clearWalletId: true)),
                ),
                ...walletsProvider.wallets.map((wallet) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildFilterChip(
                      label: wallet.name,
                      isSelected: _currentFilter.walletId == wallet.id,
                      onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(walletId: wallet.id)),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Categorías
          Text('Categoría', style: _labelStyle()),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todas',
                  isSelected: _currentFilter.categoryId == null,
                  onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(clearCategoryId: true)),
                ),
                ...movementsProvider.categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildFilterChip(
                      label: cat.name,
                      isSelected: _currentFilter.categoryId == cat.id,
                      onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(categoryId: cat.id)),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Etiquetas
          Text('Etiqueta', style: _labelStyle()),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Todas',
                  isSelected: _currentFilter.tagId == null,
                  onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(clearTagId: true)),
                ),
                ...movementsProvider.tags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _buildFilterChip(
                      label: tag.name,
                      isSelected: _currentFilter.tagId == tag.id,
                      onSelected: (_) => setState(() => _currentFilter = _currentFilter.copyWith(tagId: tag.id)),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde.solid,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(_currentFilter),
            child: Text(
              'Aplicar Filtros',
              style: AppFonts.montserrat(
                color: AppColors.blanco.solid,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  TextStyle _labelStyle() {
    return AppFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.negro.withOpacity(0.7),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required Function(bool) onSelected}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.verde.withOpacity(0.2),
      checkmarkColor: AppColors.verde.solid,
      labelStyle: AppFonts.montserrat(
        color: isSelected ? AppColors.verde.solid : AppColors.negro.solid,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.negro.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.verde.solid : Colors.transparent,
        ),
      ),
    );
  }
}
