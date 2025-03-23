// lib/core/widgets/debug_location_panel.dart
import 'package:flutter/material.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

class DebugLocationPanel extends StatelessWidget {
  final Location? location;
  final VoidCallback? onRefresh;

  const DebugLocationPanel({
    Key? key, 
    this.location,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (location == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'DEBUG: Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (onRefresh != null)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  onPressed: onRefresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          Text('Lat: ${location!.latitude.toStringAsFixed(6)}'),
          Text('Lng: ${location!.longitude.toStringAsFixed(6)}'),
          if (location!.formattedAddress != null)
            Text(
              'Address: ${location!.formattedAddress}',
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}