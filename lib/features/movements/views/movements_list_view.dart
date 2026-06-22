import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/features/movements/providers/movements_provider.dart';
import 'package:alza/features/home/providers/home_provider.dart';
import 'package:alza/features/movements/views/components/movement_item.dart';
import 'package:alza/features/movements/views/components/movements_filter_sheet.dart';

class MovementsListView extends StatefulWidget {
  const MovementsListView({super.key});

  @override
  State<MovementsListView> createState() => _MovementsListViewState();
}

class _MovementsListViewState extends State<MovementsListView> {
  MovementsFilter _currentFilter = MovementsFilter();
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (homeProvider.selectedWalletId.isNotEmpty) {
        _currentFilter = MovementsFilter(walletId: homeProvider.selectedWalletId);
      }
      _isInit = true;
    }
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<MovementsFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MovementsFilterSheet(initialFilter: _currentFilter),
    );

    if (result != null) {
      setState(() {
        _currentFilter = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final movementsProvider = Provider.of<MovementsProvider>(context);
    
    // Aplicar filtros
    final filteredMovements = movementsProvider.movements.where((movement) {
      if (_currentFilter.type != null && movement.type != _currentFilter.type) {
        return false;
      }
      if (_currentFilter.walletId != null && movement.walletId != _currentFilter.walletId) {
        return false;
      }
      if (_currentFilter.categoryId != null && movement.categoryId != _currentFilter.categoryId) {
        return false;
      }
      if (_currentFilter.tagId != null && !movement.tags.any((tag) => tag.id == _currentFilter.tagId)) {
        return false;
      }
      return true;
    }).toList();

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.negro.solid),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Historial de Movimientos',
            style: AppFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.negro.solid,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _hasActiveFilters() ? Icons.filter_list : Icons.filter_list_outlined,
                color: _hasActiveFilters() ? AppColors.verde.solid : AppColors.negro.solid,
              ),
              onPressed: _showFilterSheet,
            ),
          ],
        ),
        body: SafeArea(
          child: movementsProvider.isLoading && movementsProvider.movements.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D764)),
                  ),
                )
              : filteredMovements.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'No se encontraron movimientos con los filtros actuales.',
                          style: AppFonts.montserrat(
                            fontSize: 14,
                            color: AppColors.negro.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      itemCount: filteredMovements.length,
                      itemBuilder: (context, index) {
                        return MovementItem(movement: filteredMovements[index]);
                      },
                    ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _currentFilter.type != null ||
        _currentFilter.walletId != null ||
        _currentFilter.categoryId != null ||
        _currentFilter.tagId != null;
  }
}
