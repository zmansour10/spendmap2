import 'package:flutter/material.dart';

class IconPickerDialog extends StatefulWidget {
  const IconPickerDialog({
    super.key,
    this.selectedIconCode,
  });

  final int? selectedIconCode;

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  int? _selectedIconCode;
  String _searchQuery = '';

  static const List<IconData> _categoryIcons = [
    // Food & Dining
    Icons.restaurant,
    Icons.local_dining,
    Icons.local_bar,
    Icons.local_cafe,
    Icons.cake,
    Icons.local_pizza,
    Icons.lunch_dining,
    Icons.breakfast_dining,
    Icons.dinner_dining,
    Icons.fastfood,
    Icons.icecream,
    Icons.wine_bar,
    
    // Transportation
    Icons.directions_car,
    Icons.local_gas_station,
    Icons.train,
    Icons.flight,
    Icons.directions_bus,
    Icons.motorcycle,
    Icons.pedal_bike,
    Icons.local_taxi,
    Icons.subway,
    Icons.directions_boat,
    Icons.local_shipping,
    Icons.airport_shuttle,
    
    // Shopping
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.store,
    Icons.local_mall,
    Icons.storefront,
    Icons.local_grocery_store,
    Icons.local_pharmacy,
    Icons.local_florist,
    Icons.local_offer,
    Icons.receipt_long,
    Icons.payment,
    Icons.credit_card,
    
    // Entertainment
    Icons.movie,
    Icons.theater_comedy,
    Icons.music_note,
    Icons.sports_basketball,
    Icons.sports_soccer,
    Icons.games,
    Icons.casino,
    Icons.celebration,
    Icons.nightlife,
    Icons.festival,
    Icons.beach_access,
    Icons.pool,
    
    // Health & Fitness
    Icons.local_hospital,
    Icons.medical_services,
    Icons.fitness_center,
    Icons.spa,
    Icons.healing,
    Icons.psychology,
    Icons.medication,
    Icons.vaccines,
    Icons.monitor_heart,
    Icons.self_improvement,
    Icons.sports_gymnastics,
    Icons.sports_tennis,
    
    // Education
    Icons.school,
    Icons.library_books,
    Icons.book,
    Icons.computer,
    Icons.science,
    Icons.calculate,
    Icons.edit,
    Icons.assignment,
    Icons.laptop,
    Icons.tablet,
    Icons.phone,
    Icons.headphones,
    
    // Home & Utilities
    Icons.home,
    Icons.electrical_services,
    Icons.water_drop,
    Icons.local_fire_department,
    Icons.wifi,
    Icons.phone,
    Icons.tv,
    Icons.kitchen,
    Icons.bed,
    Icons.shower,
    Icons.lightbulb,
    Icons.air,
    
    // Personal Care
    Icons.face,
    Icons.content_cut,
    Icons.checkroom,
    Icons.dry_cleaning,
    Icons.local_laundry_service,
    Icons.shopping_basket,
    Icons.watch,
    Icons.diamond,
    Icons.brush,
    Icons.palette,
    Icons.style,
    Icons.favorite,
    
    // Business & Work
    Icons.work,
    Icons.business_center,
    Icons.meeting_room,
    Icons.print,
    Icons.scanner,
    Icons.description,
    Icons.folder,
    Icons.campaign,
    Icons.trending_up,
    Icons.analytics,
    Icons.pie_chart,
    Icons.bar_chart,
    
    // Travel
    Icons.luggage,
    Icons.hotel,
    Icons.local_hotel,
    Icons.camera_alt,
    Icons.map,
    Icons.explore,
    Icons.public,
    Icons.language,
    Icons.tour,
    Icons.hiking,
    Icons.terrain,
    Icons.nature,
    
    // Finance
    Icons.account_balance,
    Icons.savings,
    Icons.money,
    Icons.currency_exchange,
    Icons.credit_score,
    Icons.receipt,
    Icons.local_atm,
    Icons.account_balance_wallet,
    Icons.monetization_on,
    Icons.paid,
    Icons.price_change,
    Icons.request_quote,
    
    // Miscellaneous
    Icons.category,
    Icons.star,
    Icons.label,
    Icons.bookmark,
    Icons.flag,
    Icons.lock,
    Icons.key,
    Icons.schedule,
    Icons.event,
    Icons.today,
    Icons.calendar_month,
    Icons.alarm,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIconCode = widget.selectedIconCode;
  }

  List<IconData> get _filteredIcons {
    if (_searchQuery.isEmpty) return _categoryIcons;
    
    // Simple search - you could enhance this with better matching
    return _categoryIcons.where((icon) {
      final iconName = _getIconName(icon).toLowerCase();
      return iconName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _getIconName(IconData icon) {
    // Convert icon codePoint to a readable name (simplified)
    final codePoint = icon.codePoint;
    final iconEntry = _iconNameMap[codePoint];
    return iconEntry ?? 'Icon ${codePoint.toString()}';
  }

  static const Map<int, String> _iconNameMap = {
    // Add mappings for better search functionality
    58732: 'restaurant',
    58733: 'dining',
    58734: 'bar',
    58735: 'cafe',
    // Add more as needed...
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose Icon',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search icons...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Icon grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _filteredIcons.length,
                itemBuilder: (context, index) {
                  final icon = _filteredIcons[index];
                  final isSelected = _selectedIconCode == icon.codePoint;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIconCode = icon.codePoint;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade700,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedIconCode != null
                          ? () => Navigator.pop(context, _selectedIconCode)
                          : null,
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}