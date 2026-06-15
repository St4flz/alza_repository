import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/ui/text_box.dart';
import 'package:alza/shared/components/ui/button.dart';

class UsernameModal extends StatefulWidget {
  final Future<bool> Function(String) onSave;

  const UsernameModal({super.key, required this.onSave});

  @override
  State<UsernameModal> createState() => _UsernameModalState();
}

class _UsernameModalState extends State<UsernameModal> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'El nombre de usuario no puede estar vacío';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[USERNAME MODAL] Guardando nombre de usuario: $name');
      final success = await widget.onSave(name);
      debugPrint('[USERNAME MODAL] Guardado completado con éxito: $success');
      if (success) {
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No se pudo guardar el nombre de usuario. Reintenta.';
          });
        }
      }
    } catch (e) {
      debugPrint('[USERNAME MODAL] ERROR al guardar nombre de usuario: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ocurrió un error inesperado al guardar.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We prevent dismissing the dialog by pressing the system back button
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.negro.solid.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.verde.solid.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.verde.solid.withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.verde.withOpacity(0.12),
                ),
                child: Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.verde.solid,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Bienvenido a Alza+!',
                style: AppFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.verde.solid,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Elige un nombre de usuario para personalizar tus reportes y tu experiencia en la aplicación.',
                textAlign: TextAlign.center,
                style: AppFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blanco.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              CajaTexto(
                hintText: 'Nombre de usuario',
                controller: _controller,
                backgroundColor: AppColors.blanco.withOpacity(0.1),
                hintStyle: AppFonts.montserrat(
                  fontSize: 14,
                  color: AppColors.blanco.withOpacity(0.40),
                ),
                textStyle: AppFonts.montserrat(
                  fontSize: 15,
                  color: AppColors.blanco.solid,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    )
                  : Boton(
                      text: 'Guardar y Continuar',
                      backgroundColor: AppColors.verde.solid,
                      textStyle: AppFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blanco.solid,
                      ),
                      onPressed: _submit,
                      width: double.infinity,
                      height: 48,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
