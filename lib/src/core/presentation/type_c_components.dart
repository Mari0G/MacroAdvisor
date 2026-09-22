import 'package:flutter/material.dart';
import 'package:macro_advisor/src/app/app_theme.dart';

class TypeCPageHeader extends StatelessWidget {
  const TypeCPageHeader({required this.title, this.subtitle, super.key});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!, style: TextStyle(color: TypeCTokens.of(context).muted)),
      ],
    ],
  );
}

class TypeCSectionHeader extends StatelessWidget {
  const TypeCSectionHeader({required this.title, this.action, super.key});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?action,
      ],
    ),
  );
}

class TypeCNotice extends StatelessWidget {
  const TypeCNotice({required this.icon, required this.child, super.key});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: TypeCTokens.of(context).notice,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

class TypeCHeroCard extends StatelessWidget {
  const TypeCHeroCard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = TypeCTokens.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tokens.heroStart, tokens.heroEnd],
        ),
        border: Border.all(color: tokens.line),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            bottom: -80,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.heroGlow,
                boxShadow: [BoxShadow(color: tokens.heroGlow, blurRadius: 15)],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(22), child: child),
        ],
      ),
    );
  }
}

class TypeCSelectionRow extends StatelessWidget {
  const TypeCSelectionRow({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.swatch,
    super.key,
  });
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final Color swatch;

  @override
  Widget build(BuildContext context) => Semantics(
    checked: selected,
    inMutuallyExclusiveGroup: true,
    child: Material(
      color: TypeCTokens.of(context).card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minWidth: 144, minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? swatch : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 8, backgroundColor: swatch),
              const SizedBox(width: 10),
              Flexible(child: Text(title)),
              const SizedBox(width: 6),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: selected
                    ? swatch
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
