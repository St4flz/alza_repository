import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/features/home/models/cross_menu_item.dart';

class ActionCrossOverlay extends StatefulWidget {
  final VoidCallback onDefaultTap;
  final CrossMenuItem? topAction;
  final CrossMenuItem? bottomAction;
  final CrossMenuItem? leftAction;
  final CrossMenuItem? rightAction;
  final CrossMenuItem? topLeftAction;
  final CrossMenuItem? topRightAction;
  final CrossMenuItem? bottomLeftAction;
  final CrossMenuItem? bottomRightAction;
  final CrossMenuItem? leftTopAction;
  final CrossMenuItem? leftBottomAction;
  final CrossMenuItem? rightTopAction;
  final CrossMenuItem? rightBottomAction;
  final Widget child;

  const ActionCrossOverlay({
    super.key,
    required this.onDefaultTap,
    required this.child,
    this.topAction,
    this.bottomAction,
    this.leftAction,
    this.rightAction,
    this.topLeftAction,
    this.topRightAction,
    this.bottomLeftAction,
    this.bottomRightAction,
    this.leftTopAction,
    this.leftBottomAction,
    this.rightTopAction,
    this.rightBottomAction,
  });

  @override
  State<ActionCrossOverlay> createState() => _ActionCrossOverlayState();
}

class _ActionCrossOverlayState extends State<ActionCrossOverlay> {
  OverlayEntry? _overlayEntry;
  Offset _dragOffset = Offset.zero;
  String _activeSpace = '';
  String _selectedActionKey = '';

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _dragOffset = Offset.zero;
    _activeSpace = '';
    _selectedActionKey = '';
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _dragOffset = details.localOffsetFromOrigin;
    _updateSelectedDirection();
    _overlayEntry?.markNeedsBuild();
  }

  void _updateSelectedDirection() {
    final distance = _dragOffset.distance;
    if (distance < 40) {
      _activeSpace = '';
      _selectedActionKey = '';
      return;
    }

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (_activeSpace.isEmpty) {
      if (dx.abs() > dy.abs()) {
        _activeSpace = dx > 0 ? 'right' : 'left';
      } else {
        _activeSpace = dy > 0 ? 'bottom' : 'top';
      }
    }

    if (_activeSpace == 'top') {
      final ratio = dx / dy.abs();
      if (ratio < -0.4 && widget.topLeftAction != null) {
        _selectedActionKey = 'topLeft';
      } else if (ratio > 0.4 && widget.topRightAction != null) {
        _selectedActionKey = 'topRight';
      } else {
        _selectedActionKey = 'top';
      }
    } else if (_activeSpace == 'bottom') {
      final ratio = dx / dy.abs();
      if (ratio < -0.4 && widget.bottomLeftAction != null) {
        _selectedActionKey = 'bottomLeft';
      } else if (ratio > 0.4 && widget.bottomRightAction != null) {
        _selectedActionKey = 'bottomRight';
      } else {
        _selectedActionKey = 'bottom';
      }
    } else if (_activeSpace == 'left') {
      final ratio = dy / dx.abs();
      if (ratio < -0.4 && widget.leftTopAction != null) {
        _selectedActionKey = 'leftTop';
      } else if (ratio > 0.4 && widget.leftBottomAction != null) {
        _selectedActionKey = 'leftBottom';
      } else {
        _selectedActionKey = 'left';
      }
    } else if (_activeSpace == 'right') {
      final ratio = dy / dx.abs();
      if (ratio < -0.4 && widget.rightTopAction != null) {
        _selectedActionKey = 'rightTop';
      } else if (ratio > 0.4 && widget.rightBottomAction != null) {
        _selectedActionKey = 'rightBottom';
      } else {
        _selectedActionKey = 'right';
      }
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _removeOverlay();

    switch (_selectedActionKey) {
      case 'top':
        widget.topAction?.onTap();
        break;
      case 'topLeft':
        widget.topLeftAction?.onTap();
        break;
      case 'topRight':
        widget.topRightAction?.onTap();
        break;
      case 'bottom':
        widget.bottomAction?.onTap();
        break;
      case 'bottomLeft':
        widget.bottomLeftAction?.onTap();
        break;
      case 'bottomRight':
        widget.bottomRightAction?.onTap();
        break;
      case 'left':
        widget.leftAction?.onTap();
        break;
      case 'leftTop':
        widget.leftTopAction?.onTap();
        break;
      case 'leftBottom':
        widget.leftBottomAction?.onTap();
        break;
      case 'right':
        widget.rightAction?.onTap();
        break;
      case 'rightTop':
        widget.rightTopAction?.onTap();
        break;
      case 'rightBottom':
        widget.rightBottomAction?.onTap();
        break;
    }

    _dragOffset = Offset.zero;
    _activeSpace = '';
    _selectedActionKey = '';
  }

  OverlayEntry _createOverlayEntry() {
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

                        // Icons only for the selected direction
                        if (_activeSpace == 'top' && widget.topAction != null) ...[
                          Positioned(
                            top: 20,
                            child: _buildIcon(
                              widget.topAction!.icon,
                              _selectedActionKey == 'top',
                            ),
                          ),
                          if (widget.topLeftAction != null)
                            Positioned(
                              top: 20,
                              left: 70,
                              child: _buildIcon(
                                widget.topLeftAction!.icon,
                                _selectedActionKey == 'topLeft',
                              ),
                            ),
                          if (widget.topRightAction != null)
                            Positioned(
                              top: 20,
                              right: 70,
                              child: _buildIcon(
                                widget.topRightAction!.icon,
                                _selectedActionKey == 'topRight',
                              ),
                            ),
                        ],
                        if (_activeSpace == 'bottom' && widget.bottomAction != null) ...[
                          Positioned(
                            bottom: 20,
                            child: _buildIcon(
                              widget.bottomAction!.icon,
                              _selectedActionKey == 'bottom',
                            ),
                          ),
                          if (widget.bottomLeftAction != null)
                            Positioned(
                              bottom: 20,
                              left: 70,
                              child: _buildIcon(
                                widget.bottomLeftAction!.icon,
                                _selectedActionKey == 'bottomLeft',
                              ),
                            ),
                          if (widget.bottomRightAction != null)
                            Positioned(
                              bottom: 20,
                              right: 70,
                              child: _buildIcon(
                                widget.bottomRightAction!.icon,
                                _selectedActionKey == 'bottomRight',
                              ),
                            ),
                        ],
                        if (_activeSpace == 'left' && widget.leftAction != null) ...[
                          Positioned(
                            left: 30,
                            child: _buildIcon(
                              widget.leftAction!.icon,
                              _selectedActionKey == 'left',
                            ),
                          ),
                          if (widget.leftTopAction != null)
                            Positioned(
                              top: 20,
                              left: 30,
                              child: _buildIcon(
                                widget.leftTopAction!.icon,
                                _selectedActionKey == 'leftTop',
                              ),
                            ),
                          if (widget.leftBottomAction != null)
                            Positioned(
                              bottom: 20,
                              left: 30,
                              child: _buildIcon(
                                widget.leftBottomAction!.icon,
                                _selectedActionKey == 'leftBottom',
                              ),
                            ),
                        ],
                        if (_activeSpace == 'right' && widget.rightAction != null) ...[
                          Positioned(
                            right: 30,
                            child: _buildIcon(
                              widget.rightAction!.icon,
                              _selectedActionKey == 'right',
                            ),
                          ),
                          if (widget.rightTopAction != null)
                            Positioned(
                              top: 20,
                              right: 30,
                              child: _buildIcon(
                                widget.rightTopAction!.icon,
                                _selectedActionKey == 'rightTop',
                              ),
                            ),
                          if (widget.rightBottomAction != null)
                            Positioned(
                              bottom: 20,
                              right: 30,
                              child: _buildIcon(
                                widget.rightBottomAction!.icon,
                                _selectedActionKey == 'rightBottom',
                              ),
                            ),
                        ],

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

