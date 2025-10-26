import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(theme)),
            ),
          )
        else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20),
          const SizedBox(width: 8),
        ],
        if (!widget.isLoading)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: _getTextColor(theme),
            ),
            child: Text(widget.text),
          ),
      ],
    );

    if (widget.isFullWidth) {
      buttonChild = SizedBox(width: double.infinity, child: buttonChild);
    }

    Widget animatedButton = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: widget.type == ButtonType.primary && _isPressed
                  ? [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppTheme.primaryGreen)
                            .withValues(alpha: 0.4 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppTheme.primaryGreen)
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: child,
          ),
        );
      },
      child: _buildButton(theme),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: animatedButton,
    );
  }

  Widget _buildButton(ThemeData theme) {
    final borderRadius = BorderRadius.circular(12);

    switch (widget.type) {
      case ButtonType.primary:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.backgroundColor ?? AppTheme.primaryGreen,
                (widget.backgroundColor ?? AppTheme.primaryGreen).withValues(
                  alpha: 0.8,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius,
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium,
              ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? AppTheme.textPrimary,
                      ),
                    ),
                  )
                else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.textColor ?? AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 8),
                ],
                if (!widget.isLoading)
                  Text(
                    widget.text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: widget.textColor ?? AppTheme.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        );

      case ButtonType.secondary:
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.darkCard,
            borderRadius: borderRadius,
            border: Border.all(color: AppTheme.darkBorder, width: 1),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium,
              ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? AppTheme.textPrimary,
                      ),
                    ),
                  )
                else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.textColor ?? AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 8),
                ],
                if (!widget.isLoading)
                  Text(
                    widget.text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: widget.textColor ?? AppTheme.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        );

      case ButtonType.outline:
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: widget.backgroundColor ?? AppTheme.primaryGreen,
              width: 2,
            ),
          ),
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium,
              ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? AppTheme.primaryGreen,
                      ),
                    ),
                  )
                else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.textColor ?? AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                ],
                if (!widget.isLoading)
                  Text(
                    widget.text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: widget.textColor ?? AppTheme.primaryGreen,
                    ),
                  ),
              ],
            ),
          ),
        );

      case ButtonType.text:
        return Container(
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingMedium,
              ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.textColor ?? AppTheme.primaryGreen,
                      ),
                    ),
                  )
                else if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.textColor ?? AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                ],
                if (!widget.isLoading)
                  Text(
                    widget.text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: widget.textColor ?? AppTheme.primaryGreen,
                    ),
                  ),
              ],
            ),
          ),
        );
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return widget.textColor ?? AppTheme.textPrimary;
      case ButtonType.outline:
      case ButtonType.text:
        return widget.textColor ?? AppTheme.primaryGreen;
    }
  }
}
