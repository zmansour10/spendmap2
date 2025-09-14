import 'package:flutter/material.dart';

class CurrencySelector extends StatelessWidget {
  final String currentCurrency;
  final Function(String) onCurrencyChanged;

  const CurrencySelector({
    super.key,
    required this.currentCurrency,
    required this.onCurrencyChanged,
  });

  static const List<Map<String, String>> supportedCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'KRW', 'name': 'South Korean Won', 'symbol': '₩'},
    {'code': 'SEK', 'name': 'Swedish Krona', 'symbol': 'kr'},
    {'code': 'NOK', 'name': 'Norwegian Krone', 'symbol': 'kr'},
    {'code': 'DKK', 'name': 'Danish Krone', 'symbol': 'kr'},
    {'code': 'PLN', 'name': 'Polish Zloty', 'symbol': 'zł'},
    {'code': 'CZK', 'name': 'Czech Koruna', 'symbol': 'Kč'},
    {'code': 'HUF', 'name': 'Hungarian Forint', 'symbol': 'Ft'},
    {'code': 'RUB', 'name': 'Russian Ruble', 'symbol': '₽'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$'},
    {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': '\$'},
    {'code': 'ARS', 'name': 'Argentine Peso', 'symbol': '\$'},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCurrency = supportedCurrencies.firstWhere(
      (currency) => currency['code'] == currentCurrency,
      orElse: () => supportedCurrencies.first,
    );

    return ListTile(
      title: const Text('Currency'),
      subtitle: Text('${selectedCurrency['name']} (${selectedCurrency['symbol']})'),
      leading: const Icon(Icons.attach_money),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCurrencyPicker(context),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Select Currency',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = supportedCurrencies[index];
                    final isSelected = currency['code'] == currentCurrency;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Text(
                          currency['symbol']!,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(currency['name']!),
                      subtitle: Text('${currency['code']} • ${currency['symbol']}'),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        onCurrencyChanged(currency['code']!);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String getCurrencySymbol(String currencyCode) {
    final currency = supportedCurrencies.firstWhere(
      (currency) => currency['code'] == currencyCode,
      orElse: () => supportedCurrencies.first,
    );
    return currency['symbol']!;
  }

  static String getCurrencyName(String currencyCode) {
    final currency = supportedCurrencies.firstWhere(
      (currency) => currency['code'] == currencyCode,
      orElse: () => supportedCurrencies.first,
    );
    return currency['name']!;
  }
}