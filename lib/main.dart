import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'features/expenses/presentation/screens/expense_list_screen.dart';
import 'features/categories/presentation/screens/category_management_screen.dart';
import 'features/expenses/presentation/screens/add_expense_screen.dart';
import 'features/statistics/presentation/screens/statistics_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/shared/providers/locale_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(currentLocaleProvider);
    final themeMode = ref.watch(currentThemeProvider);

    return MaterialApp(
      title: 'SpendMap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case ExpenseListScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const ExpenseListScreen(),
            );
          case CategoryManagementScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const CategoryManagementScreen(),
            );
          case StatisticsScreen.routeName:
            return MaterialPageRoute(
              builder: (context) => const StatisticsScreen(),
            );
          case AddExpenseScreen.routeName:
            // Extract arguments if provided
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => AddExpenseScreen(
                initialExpense: args?['initialExpense'],
                templateAmount: args?['templateAmount'],
                templateDescription: args?['templateDescription'],
                templateCategoryId: args?['templateCategoryId'],
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const ExpenseListScreen(),
    const CategoryManagementScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: localizations?.expenses ?? 'Expenses',
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: localizations?.categories ?? 'Categories',
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: localizations?.statistics ?? 'Statistics',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: localizations?.settings ?? 'Settings',
          ),
        ],
      ),
    );
  }
}
