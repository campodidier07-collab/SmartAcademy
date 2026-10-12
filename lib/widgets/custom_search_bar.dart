import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    this.hint = 'Buscar...',
    this.onChanged,
    this.controller,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText && mounted) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (focus) {
          setState(() {
            _isFocused = focus;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: _isFocused ? AppTheme.cardBase : AppTheme.cardElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused ? AppTheme.primaryBlue : AppTheme.borderLight,
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    )
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: GoogleFonts.outfit(
              color: AppTheme.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: GoogleFonts.outfit(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                LucideIcons.search,
                color: _isFocused ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 18,
              ),
              suffixIcon: _hasText
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.textSecondary),
                      onPressed: () {
                        _controller.clear();
                        if (widget.onChanged != null) widget.onChanged!('');
                      },
                      splashRadius: 16,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
