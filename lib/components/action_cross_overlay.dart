import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';

class CrossMenuItem {
  final IconData icon;
  final VoidCallback onTap;

  CrossMenuItem({required this.icon, required this.onTap});
}

class ActionCrossOverlay extends StatefulWidget {
  final VoidCallback onDefaultTap;
  final CrossMenuItem? topAction;
  final CrossMenuItem? bottomAction;
  final CrossMenuItem? leftAction;
  final CrossMenuItem? rightAction;
  final Widget child;

  const ActionCrossOverlay({
    super.key,
    required this.onDefaultTap,
    required this.child,
    this.topAction,
    this.bottomAction,
    this.leftAction,
    this.rightAction,
  });

  @override
  State<ActionCrossOverlay> createState() => _ActionCrossOverlayState();
}

class _ActionCrossOverlayState extends State<ActionCrossOverlay>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Offset _dragOffset = Offset.zero;
  String _selectedDirection = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _dragOffset = Offset.zero;
    _selectedDirection = '';
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _dragOffset = details.localOffsetFromOrigin;
    _updateSelectedDirection();
    _overlayEntry?.markNeedsBuild();
  }

  void _updateSelectedDirection() {
    if (_dragOffset.distance < 40) {
      _selectedDirection = '';
      return;
    }

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dx.abs() > dy.abs()) {
      _selectedDirection = dx > 0 ? 'right' : 'left';
    } else {
      _selectedDirection = dy > 0 ? 'bottom' : 'top';
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _removeOverlay();

    if (_selectedDirection == 'top' && widget.topAction != null) {
      widget.topAction!.onTap();
    } else if (_selectedDirection == 'bottom' && widget.bottomAction != null) {
      widget.bottomAction!.onTap();
    } else if (_selectedDirection == 'left' && widget.leftAction != null) {
      widget.leftAction!.onTap();
    } else if (_selectedDirection == 'right' && widget.rightAction != null) {
      widget.rightAction!.onTap();
    }

    _dragOffset = Offset.zero;
    _selectedDirection = '';
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    width: 340,
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.negro.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Tracks
                        Container(
                          width: 60,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.negro.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        Container(
                          width: 280,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.negro.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),

                        // Icons
                        if (widget.topAction != null)
                          Positioned(
                            top: 20,
                            child: _buildIcon(
                              widget.topAction!.icon,
                              _selectedDirection == 'top',
                            ),
                          ),
                        if (widget.bottomAction != null)
                          Positioned(
                            bottom: 20,
                            child: _buildIcon(
                              widget.bottomAction!.icon,
                              _selectedDirection == 'bottom',
                            ),
                          ),
                        if (widget.leftAction != null)
                          Positioned(
                            left: 30,
                            child: _buildIcon(
                              widget.leftAction!.icon,
                              _selectedDirection == 'left',
                            ),
                          ),
                        if (widget.rightAction != null)
                          Positioned(
                            right: 30,
                            child: _buildIcon(
                              widget.rightAction!.icon,
                              _selectedDirection == 'right',
                            ),
                          ),

                        // Draw dashed line
                        CustomPaint(
                          painter: _DashedLinePainter(
                            start: Offset.zero,
                            end: _dragOffset,
                            color: AppColors.verde.solid,
                          ),
                          size: const Size(double.infinity, double.infinity),
                        ),

                        // Pulsing cursor
                        Transform.translate(
                          offset: _dragOffset,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseScale.value,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.verde.solid.withOpacity(
                                        0.4,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.verde.solid,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Fake center button to match overlay visually
                        Positioned(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blanco.solid,
                              border: Border.all(
                                color: AppColors.verde.solid,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.playlist_add,
                              color: AppColors.verde.solid,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Icon(
      icon,
      color: isSelected
          ? AppColors.negro.solid
          : AppColors.negro.withOpacity(0.5),
      size: 28,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDefaultTap,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      onLongPressEnd: _handleLongPressEnd,
      onLongPressCancel: _removeOverlay,
      child: widget.child,
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  _DashedLinePainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final p1 = center + start;
    final p2 = center + end;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double distance = (p2 - p1).distance;
    if (distance < 15) return;

    final direction = (p2 - p1) / distance;

    // Start drawing a bit outside the center
    final startOffset = p1 + direction * 25;
    double drawnLength = 25.0;

    const dashWidth = 5.0;
    const dashSpace = 6.0;

    while (drawnLength < distance - 25) {
      // Stop before reaching the cursor
      final currentP1 = p1 + direction * drawnLength;
      drawnLength += dashWidth;
      final endLength = drawnLength > (distance - 25)
          ? (distance - 25)
          : drawnLength;
      final currentP2 = p1 + direction * endLength;
      canvas.drawLine(currentP1, currentP2, paint);
      drawnLength += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
