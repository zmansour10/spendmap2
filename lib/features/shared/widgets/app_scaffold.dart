import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.titleWidget,
    this.leading,
    this.resizeToAvoidBottomInset,
  });

  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final double elevation;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Widget? titleWidget;
  final Widget? leading;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        title: titleWidget ?? Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: centerTitle,
        elevation: elevation,
        backgroundColor: appBarBackgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        automaticallyImplyLeading: automaticallyImplyLeading && (showBackButton || Navigator.canPop(context)),
        leading: leading ?? (showBackButton ? const _BackButton() : null),
        actions: actions,
        systemOverlayStyle: _getSystemOverlayStyle(context),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness == Brightness.dark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_ios_new),
      tooltip: 'Back',
    );
  }
}

/// App scaffold with search functionality
class SearchableAppScaffold extends StatefulWidget {
  const SearchableAppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.onSearchChanged,
    this.searchHint = 'Search...',
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.initialSearchQuery = '',
  });

  final String title;
  final Widget body;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final String initialSearchQuery;

  @override
  State<SearchableAppScaffold> createState() => _SearchableAppScaffoldState();
}

class _SearchableAppScaffoldState extends State<SearchableAppScaffold>
    with SingleTickerProviderStateMixin {
  bool _isSearchActive = false;
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchQuery);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.initialSearchQuery.isNotEmpty) {
      _isSearchActive = true;
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        widget.onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      showBackButton: widget.showBackButton,
      backgroundColor: widget.backgroundColor,
      titleWidget: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _animation.value > 0.5
              ? _buildSearchField()
              : Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                );
        },
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(_isSearchActive ? Icons.close : Icons.search),
          tooltip: _isSearchActive ? 'Close search' : 'Search',
        ),
        ...?widget.actions,
      ],
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      drawer: widget.drawer,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: widget.onSearchChanged,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.searchHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.6),
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).appBarTheme.foregroundColor,
        fontSize: 16,
      ),
      cursorColor: Theme.of(context).appBarTheme.foregroundColor,
    );
  }
}