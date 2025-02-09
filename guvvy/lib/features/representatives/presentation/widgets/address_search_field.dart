// lib/features/representatives/presentation/widgets/address_search_field.dart
import 'package:flutter/material.dart';

class AddressSearchField extends StatelessWidget {
  final Function(double latitude, double longitude) onAddressSelected;

  const AddressSearchField({
    Key? key,
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter your address...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Icons.search, color: theme.primaryColor),
        ),
        style: theme.textTheme.bodyLarge,
        onSubmitted: (value) {
          // TODO: Implement address geocoding
          onAddressSelected(37.7749, -122.4194);
        },
      ),
    );
  }
}

// lib/features/representatives/presentation/widgets/filter_chips.dart
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