// lib/features/representatives/presentation/widgets/filter_chips.dart
import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Text(
              'Federal',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.primaryColor,
              ),
            ),
            selected: true,
            onSelected: (bool selected) {
              // TODO: Implement filtering
            },
            selectedColor: theme.primaryColor.withOpacity(0.1),
            backgroundColor: theme.chipTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              'State',
              style: theme.textTheme.bodyMedium,
            ),
            selected: false,
            onSelected: (bool selected) {
              // TODO: Implement filtering
            },
            backgroundColor: theme.chipTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              'Local',
              style: theme.textTheme.bodyMedium,
            ),
            selected: false,
            onSelected: (bool selected) {
              // TODO: Implement filtering
            },
            backgroundColor: theme.chipTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
