import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool isCompleted;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.isCompleted = false,
    this.trailing,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (widget.isCompleted)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                    ),
                  if (widget.trailing != null) widget.trailing!,
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: widget.child,
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0, duration: 300.ms),
        ],
      ),
    );
  }
}
