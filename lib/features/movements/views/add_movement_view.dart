import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';
import 'package:alza/features/movements/models/category_model.dart';
import 'package:alza/features/movements/models/tag_model.dart';
import 'package:alza/features/movements/providers/movements_provider.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMovementView extends StatefulWidget {
  const AddMovementView({super.key});

  @override
  State<AddMovementView> createState() => _AddMovementViewState();
}

class _AddMovementViewState extends State<AddMovementView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _type = 'expense'; // 'expense' | 'income'
  Wallet? _selectedWallet;
  Category? _selectedCategory;
  final List<Tag> _selectedTags = [];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _lastGeneratedTitle = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final movementsProvider = Provider.of<MovementsProvider>(context, listen: false);
      final walletsProvider = Provider.of<WalletsProvider>(context, listen: false);

      await movementsProvider.fetchCategories();
      await movementsProvider.fetchTags();
      await walletsProvider.fetchWallets();

      if (walletsProvider.wallets.isNotEmpty) {
        setState(() {
          _selectedWallet = walletsProvider.wallets.first;
        });
        _updateDefaultTitle();
      }

      if (movementsProvider.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = movementsProvider.categories.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateDefaultTitle() async {
    if (_selectedWallet == null) return;
    final movementsProvider = Provider.of<MovementsProvider>(context, listen: false);
    final count = await movementsProvider.fetchTransactionCount(_selectedWallet!.id);

    final typeText = _type == 'expense' ? 'Gasto' : 'Ingreso';
    final generatedTitle = '$typeText ${_selectedWallet!.name} ${count + 1}';

    if (_titleController.text.isEmpty || _titleController.text == _lastGeneratedTitle) {
      setState(() {
        _titleController.text = generatedTitle;
        _lastGeneratedTitle = generatedTitle;
      });
    }
  }

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    bool isSaving = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.blanco.solid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Text(
                'Nueva Categoría',
                style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.negro.solid),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la categoría',
                      hintText: 'Ej. Supermercado',
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    setDialogState(() {
                      isSaving = true;
                      errorMsg = null;
                    });

                    final movementsProvider = Provider.of<MovementsProvider>(context, listen: false);
                    final newCategory = await movementsProvider.createCategory(name);

                    if (newCategory != null) {
                      if (context.mounted) {
                        setState(() {
                          _selectedCategory = newCategory;
                        });
                        Navigator.pop(context);
                      }
                    } else {
                      setDialogState(() {
                        isSaving = false;
                        errorMsg = movementsProvider.errorMessage ?? 'Error al crear la categoría';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.negro.solid,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Crear', style: TextStyle(color: AppColors.blanco.solid)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTagDialog() {
    final nameCtrl = TextEditingController();
    bool isSaving = false;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.blanco.solid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Text(
                'Nueva Etiqueta',
                style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.negro.solid),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la etiqueta',
                      hintText: 'Ej. Mensual',
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    setDialogState(() {
                      isSaving = true;
                      errorMsg = null;
                    });

                    final movementsProvider = Provider.of<MovementsProvider>(context, listen: false);
                    final newTag = await movementsProvider.createTag(name);

                    if (newTag != null) {
                      if (context.mounted) {
                        setState(() {
                          if (!_selectedTags.any((t) => t.id == newTag.id)) {
                            _selectedTags.add(newTag);
                          }
                        });
                        Navigator.pop(context);
                      }
                    } else {
                      setDialogState(() {
                        isSaving = false;
                        errorMsg = movementsProvider.errorMessage ?? 'Error al crear la etiqueta';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.negro.solid,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Crear', style: TextStyle(color: AppColors.blanco.solid)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una billetera.')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La categoría es obligatoria.')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monto inválido.')),
      );
      return;
    }

    if (_type == 'expense' && _selectedWallet!.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo insuficiente en la billetera para realizar este gasto.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final provider = Provider.of<MovementsProvider>(context, listen: false);
    final walletsProvider = Provider.of<WalletsProvider>(context, listen: false);

    final success = await provider.createMovement(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
      amount: amount,
      type: _type,
      walletId: _selectedWallet!.id,
      categoryId: _selectedCategory!.id,
      tagIds: _selectedTags.map((t) => t.id).toList(),
    );

    if (success) {
      // Recargar billeteras para tener saldos frescos
      await walletsProvider.fetchWallets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movimiento registrado con éxito.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Error al crear el movimiento.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _processReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      
      final movementsProvider = Provider.of<MovementsProvider>(context, listen: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procesando recibo, por favor espera...')),
        );
      }

      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Upload to Supabase
      await Supabase.instance.client.storage
          .from('receipt_images')
          .upload(fileName, file);
          
      final imageUrl = Supabase.instance.client.storage
          .from('receipt_images')
          .getPublicUrl(fileName);
          
      // Process with backend
      final data = await movementsProvider.processReceipt(imageUrl);
      
      if (data != null && mounted) {
        setState(() {
          if (data['amount'] != null) _amountController.text = data['amount'].toString();
          if (data['raw_text'] != null) _titleController.text = data['raw_text'];
          // Intentar seleccionar categoría automáticamente
          if (data['category_hint'] != null) {
            final hint = data['category_hint'].toString().toLowerCase();
            try {
              _selectedCategory = movementsProvider.categories.firstWhere(
                (c) => c.name.toLowerCase().contains(hint)
              );
            } catch (e) {
              // No encontrada
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos extraídos exitosamente.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar recibo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = Provider.of<WalletsProvider>(context).wallets;
    final movementsProvider = Provider.of<MovementsProvider>(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.negro.solid),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Agregar Movimiento',
            style: AppFonts.montserrat(
              color: AppColors.negro.solid,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: AppColors.negro.solid),
              onPressed: _processReceipt,
              tooltip: 'Escanear recibo',
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Segmented Type Selector
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _type = 'expense';
                              });
                              _updateDefaultTitle();
                              _formKey.currentState?.validate();
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _type == 'expense' ? Colors.redAccent : Colors.grey[200],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Gasto',
                                style: AppFonts.montserrat(
                                  color: _type == 'expense' ? AppColors.blanco.solid : AppColors.negro.solid,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _type = 'income';
                              });
                              _updateDefaultTitle();
                              _formKey.currentState?.validate();
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: _type == 'income' ? AppColors.verde.solid : Colors.grey[200],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Ingreso',
                                style: AppFonts.montserrat(
                                  color: _type == 'income' ? AppColors.blanco.solid : AppColors.negro.solid,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Wallet Selector
                    Text('Billetera', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.negro.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.blanco.solid,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Wallet>(
                          value: _selectedWallet,
                          hint: const Text('Seleccionar billetera'),
                          isExpanded: true,
                          items: wallets.map((wallet) {
                            return DropdownMenuItem<Wallet>(
                              value: wallet,
                              child: Text('${wallet.name} (${wallet.balance.toStringAsFixed(0)} \$)', style: AppFonts.montserrat()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedWallet = val;
                            });
                            _updateDefaultTitle();
                            _formKey.currentState?.validate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categoría', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.negro.withOpacity(0.5))),
                        GestureDetector(
                          onTap: _showAddCategoryDialog,
                          child: Text('+ Categoría', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.verde.solid)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.blanco.solid,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Category>(
                          value: _selectedCategory,
                          hint: const Text('Seleccionar categoría'),
                          isExpanded: true,
                          items: movementsProvider.categories.map((cat) {
                            return DropdownMenuItem<Category>(
                              value: cat,
                              child: Text(cat.name, style: AppFonts.montserrat()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount Field
                    Text('Monto', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.negro.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: AppFonts.montserrat(fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.blanco.solid,
                        hintText: 'Ej. 15000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Requerido';
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null) return 'Ingresar número';
                        if (parsed <= 0) return 'El monto debe ser mayor a 0';
                        if (_type == 'expense' && _selectedWallet != null && _selectedWallet!.balance < parsed) {
                          return 'Saldo insuficiente (${_selectedWallet!.balance.toStringAsFixed(0)} \$)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Title Field (Default populated but editable)
                    Text('Concepto (Título)', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.negro.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: AppFonts.montserrat(fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.blanco.solid,
                        hintText: 'Ej. Compra semanal',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'El título es requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Tags selector (Wrap with filter chips)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Etiquetas', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.negro.withOpacity(0.5))),
                        GestureDetector(
                          onTap: _showAddTagDialog,
                          child: Text('+ Etiqueta', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.verde.solid)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    movementsProvider.tags.isEmpty
                        ? Text('No hay etiquetas disponibles.', style: AppFonts.montserrat(color: Colors.grey, fontSize: 12))
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: movementsProvider.tags.map((tag) {
                              final isSelected = _selectedTags.any((t) => t.id == tag.id);
                              return FilterChip(
                                label: Text(tag.name, style: AppFonts.montserrat(fontSize: 12, color: isSelected ? AppColors.blanco.solid : AppColors.negro.solid)),
                                selected: isSelected,
                                selectedColor: AppColors.verde.solid,
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTags.add(tag);
                                    } else {
                                      _selectedTags.removeWhere((t) => t.id == tag.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),

                    // Description Field
                    Text('Descripción (Opcional)', style: AppFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.negro.withOpacity(0.5))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: AppFonts.montserrat(fontSize: 16),
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.blanco.solid,
                        hintText: 'Detalles adicionales...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[300]!)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Boton(
                      text: movementsProvider.isLoading ? 'Guardando...' : 'Guardar',
                      backgroundColor: movementsProvider.isLoading 
                          ? AppColors.negro.withOpacity(0.3) 
                          : AppColors.negro.solid,
                      textStyle: AppFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blanco.solid,
                      ),
                      onPressed: () {
                        if (!movementsProvider.isLoading) {
                          _submit();
                        }
                      },
                      width: double.infinity,
                      height: 48,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
