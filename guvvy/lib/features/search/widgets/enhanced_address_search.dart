// lib/features/search/widgets/enhanced_address_search_field.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/geocoding_service.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

class EnhancedAddressSearchField extends StatefulWidget {
  final Function(Location) onAddressSelected;
  final String? initialAddress;
  final String hintText;
  final bool autofocus;

  const EnhancedAddressSearchField({
    Key? key,
    required this.onAddressSelected,
    this.initialAddress,
    this.hintText = 'Enter your address...',
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<EnhancedAddressSearchField> createState() =>
      _EnhancedAddressSearchFieldState();
}

class _EnhancedAddressSearchFieldState extends State<EnhancedAddressSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _showResults = false;
  bool _isLoading = false;
  List<GeocodingResult> _suggestions = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _controller.text = widget.initialAddress!;
    }
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showResults = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final suggestions = await GeocodingService.searchAddressSuggestions(query);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching suggestions: $e')),
        );
      }
    }
  }
  
  Future<void> _selectAddress(GeocodingResult suggestion) async {
    setState(() {
      _isLoading = true;
      _showResults = false;
      _controller.text = suggestion.description;
    });
    
    try {
      final location = await GeocodingService.getCoordinatesForAddress(
        suggestion.description,
      );
      
      if (mounted) {
        widget.onAddressSelected(location);
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting coordinates: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.location_on_outlined),
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _selectAddress(
                            GeocodingResult(
                              placeId: 'manual',
                              description: _controller.text,
                              primaryText: _controller.text,
                              secondaryText: '',
                            ),
                          );
                        }
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            autofocus: widget.autofocus,
            onChanged: (value) {
              // Only start searching after 2 characters
              if (value.length >= 2) {
                _getSuggestions(value);
              } else {
                setState(() {
                  _suggestions = [];
                });
              }
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                _selectAddress(
                  GeocodingResult(
                    placeId: 'manual',
                    description: value,
                    primaryText: value,
                    secondaryText: '',
                  ),
                );
              }
            },
          ),
        ),
        
        // Suggestions list
        if (_showResults && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                    suggestion.primaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    suggestion.secondaryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: () {
                    _selectAddress(suggestion);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}