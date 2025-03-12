// lib/features/search/widgets/enhanced_address_search.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';
import 'package:guvvy/features/search/domain/bloc/search_event.dart';
import 'package:guvvy/features/search/domain/bloc/search_state.dart';

class EnhancedAddressSearch extends StatefulWidget {
  final Function(double, double) onAddressSelected;

  const EnhancedAddressSearch({
    Key? key,
    required this.onAddressSelected,
  }) : super(key: key);

  @override
  State<EnhancedAddressSearch> createState() => _EnhancedAddressSearchState();
}

class _EnhancedAddressSearchState extends State<EnhancedAddressSearch> with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _searchFocus.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _elevationAnimation = Tween<double>(begin: 2, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }
  
  void _onFocusChange() {
    setState(() {
      _isFocused = _searchFocus.hasFocus;
    });
    
    if (_searchFocus.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.removeListener(_onFocusChange);
    _searchFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchResultsFound) {
          // Notify parent widget
          widget.onAddressSelected(
            state.location.latitude,
            state.location.longitude,
          );
        } else if (state is SearchError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: _elevationAnimation.value,
                  spreadRadius: _elevationAnimation.value / 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your Representatives',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Enter your address to discover who represents you',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: GuvvyTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFocused ? GuvvyTheme.primaryLight : Colors.grey.shade200,
                    width: _isFocused ? 2 : 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Street address, city, state...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.place_outlined,
                      color: _isFocused ? GuvvyTheme.primary : Colors.grey.shade500,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      color: GuvvyTheme.primary,
                      onPressed: () {
                        // Submit search and trigger geocoding
                        final address = _searchController.text;
                        if (address.isNotEmpty) {
                          context.read<SearchBloc>().add(
                            SearchAddressSubmitted(address),
                          );
                        }
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  style: theme.textTheme.bodyLarge,
                  onSubmitted: (address) {
                    if (address.isNotEmpty) {
                      context.read<SearchBloc>().add(
                        SearchAddressSubmitted(address),
                      );
                    }
                  },
                ),
              ),
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}