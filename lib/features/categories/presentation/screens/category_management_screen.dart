import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';
import '../widgets/category_form.dart';
import '../../domain/entities/category_entity.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  static const routeName = '/categories';

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<int> _selectedCategories = <int>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = ref.watch(categoriesProvider);

    return AppScaffold(
      title: _isSelectionMode 
          ? '${_selectedCategories.length} Selected' 
          : 'Categories',
      showBackButton: true,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _handleBulkDelete,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Selected',
          ),
          IconButton(
            onPressed: _exitSelectionMode,
            icon: const Icon(Icons.close),
            tooltip: 'Exit Selection',
          ),
        ] else ...[
          IconButton(
            onPressed: () => _showCreateCategoryDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
          ),
        ],
      ],
      body: Column(
        children: [
          // Tab bar for Default vs Custom categories
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'All Categories'),
                Tab(text: 'Custom Categories'),
              ],
            ),
          ),

          // Tab bar view
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Categories Tab
                _CategoryListView(
                  categories: allCategories,
                  isSelectionMode: _isSelectionMode,
                  selectedCategories: _selectedCategories,
                  onCategoryTap: _handleCategoryTap,
                  onCategoryLongPress: _handleCategoryLongPress,
                  onSelectionChanged: _handleSelectionChanged,
                ),

                // Custom Categories Tab
                allCategories.when(
                  data: (categories) {
                    final customCategories = categories.where((cat) => !cat.isDefault).toList();
                    return _CategoryListView(
                      categories: AsyncValue.data(customCategories),
                      isSelectionMode: _isSelectionMode,
                      selectedCategories: _selectedCategories,
                      onCategoryTap: _handleCategoryTap,
                      onCategoryLongPress: _handleCategoryLongPress,
                      onSelectionChanged: _handleSelectionChanged,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ],
            ),
          ),

          // Selection mode action bar
          if (_isSelectionMode)
            _SelectionActionBar(
              selectedCount: _selectedCategories.length,
              onDelete: _handleBulkDelete,
              onCancel: _exitSelectionMode,
            ),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              heroTag: "addCategoryFAB",
              onPressed: () => _showCreateCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
    );
  }

  void _handleCategoryTap(CategoryEntity category) {
    if (_isSelectionMode) {
      _handleSelectionChanged(category.id!, !_selectedCategories.contains(category.id));
    } else {
      _showCategoryActions(category);
    }
  }

  void _handleCategoryLongPress(CategoryEntity category) {
    if (!_isSelectionMode && !category.isDefault) {
      _enterSelectionMode();
      _handleSelectionChanged(category.id!, true);
    }
  }

  void _handleSelectionChanged(int categoryId, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategories.add(categoryId);
      } else {
        _selectedCategories.remove(categoryId);
      }
      
      if (_selectedCategories.isEmpty && _isSelectionMode) {
        _exitSelectionMode();
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedCategories.clear();
    });
  }

  void _showCategoryActions(CategoryEntity category) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _CategoryActionsBottomSheet(
        category: category,
        onEdit: () => _showEditCategoryDialog(context, category),
        onDelete: () => _handleDeleteCategory(category),
        onDuplicate: () => _handleDuplicateCategory(category),
      ),
    );
  }

  Future<void> _showCreateCategoryDialog(BuildContext context) async {
    final result = await showDialog<CategoryEntity>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: const CategoryFormDialog(),
        ),
      ),
    );

    if (result != null) {
      try {
        await ref.read(categoryRepositoryProvider).createCategory(result);
        ref.invalidate(categoriesProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditCategoryDialog(BuildContext context, CategoryEntity category) async {
    Navigator.pop(context); // Close bottom sheet
    
    final result = await showDialog<CategoryEntity>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: CategoryFormDialog(initialCategory: category),
        ),
      ),
    );

    if (result != null) {
      try {
        await ref.read(categoryRepositoryProvider).updateCategory(result);
        ref.invalidate(categoriesProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteCategory(CategoryEntity category) async {
    Navigator.pop(context); // Close bottom sheet

    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete default categories'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${category.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This will affect all expenses using this category.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(categoryRepositoryProvider).deleteCategory(category.id!);
        ref.invalidate(categoriesProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDuplicateCategory(CategoryEntity category) async {
    Navigator.pop(context); // Close bottom sheet
    
    final duplicateCategory = CategoryEntity(
      name: '${category.name} Copy',
      iconCode: category.iconCode,
      colorValue: category.colorValue,
      isDefault: false,
    );

    final result = await showDialog<CategoryEntity>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: CategoryFormDialog(initialCategory: duplicateCategory),
        ),
      ),
    );

    if (result != null) {
      try {
        await ref.read(categoryRepositoryProvider).createCategory(result);
        ref.invalidate(categoriesProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category duplicated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to duplicate category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleBulkDelete() async {
    final categoriesAsync = ref.read(categoriesProvider);
    final allCategories = categoriesAsync.value ?? [];
    final selectedNonDefault = _selectedCategories.where((id) {
      final category = allCategories.firstWhere((cat) => cat.id == id);
      return !category.isDefault;
    }).toList();

    if (selectedNonDefault.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete default categories'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${selectedNonDefault.length} Categories'),
        content: const Text('Are you sure you want to delete the selected categories?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(categoryRepositoryProvider);
        await Future.wait(
          selectedNonDefault.map((id) => repository.deleteCategory(id)),
        );
        
        ref.invalidate(categoriesProvider);
        _exitSelectionMode();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedNonDefault.length} categories deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete categories: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _CategoryListView extends StatelessWidget {
  const _CategoryListView({
    required this.categories,
    required this.isSelectionMode,
    required this.selectedCategories,
    required this.onCategoryTap,
    required this.onCategoryLongPress,
    required this.onSelectionChanged,
  });

  final AsyncValue<List<CategoryEntity>> categories;
  final bool isSelectionMode;
  final Set<int> selectedCategories;
  final ValueChanged<CategoryEntity> onCategoryTap;
  final ValueChanged<CategoryEntity> onCategoryLongPress;
  final void Function(int categoryId, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return categories.when(
      loading: () => const _CategoryListSkeleton(),
      error: (error, stack) => _CategoryListError(
        error: error.toString(),
        onRetry: () {
          // Refresh categories
        },
      ),
      data: (categoryList) {
        if (categoryList.isEmpty) {
          return const _EmptyCategoryList();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categoryList.length,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            final isSelected = selectedCategories.contains(category.id);

            return _CategoryTile(
              category: category,
              isSelected: isSelected,
              isSelectionMode: isSelectionMode,
              onTap: () => onCategoryTap(category),
              onLongPress: () => onCategoryLongPress(category),
              onSelectionChanged: (selected) => 
                  onSelectionChanged(category.id!, selected),
            );
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
  });

  final CategoryEntity category;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isSelected ? 8 : 2,
      borderRadius: BorderRadius.circular(16),
      color: isSelected 
          ? Color(category.colorValue).withOpacity(0.2)
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: category.isDefault ? null : onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: Color(category.colorValue),
                    width: 2,
                  )
                : Border.all(
                    color: Colors.grey.shade200,
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Selection checkbox (if in selection mode)
              if (isSelectionMode && !category.isDefault) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => onSelectionChanged(value ?? false),
                    activeColor: Color(category.colorValue),
                  ),
                ),
              ] else if (category.isDefault) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              // Category icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(category.colorValue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                  color: Color(category.colorValue),
                  size: 32,
                ),
              ),

              const SizedBox(height: 8),

              // Category name
              Flexible(
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Color(category.colorValue)
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 2),

              // Category type indicator
              if (category.isDefault)
                Flexible(
                  child: Text(
                    'System',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionActionBar extends StatelessWidget {
  const _SelectionActionBar({
    required this.selectedCount,
    required this.onDelete,
    required this.onCancel,
  });

  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$selectedCount item${selectedCount != 1 ? 's' : ''} selected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              color: Colors.red,
              tooltip: 'Delete',
            ),
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryActionsBottomSheet extends StatelessWidget {
  const _CategoryActionsBottomSheet({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),

          // Category preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(category.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(category.colorValue).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(category.colorValue).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                    color: Color(category.colorValue),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        category.isDefault ? 'Default Category' : 'Custom Category',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          _ActionButton(
            icon: Icons.edit,
            label: 'Edit Category',
            color: Colors.blue,
            onPressed: category.isDefault ? null : onEdit,
            isDisabled: category.isDefault,
          ),
          
          _ActionButton(
            icon: Icons.copy,
            label: 'Duplicate Category',
            color: Colors.orange,
            onPressed: onDuplicate,
          ),
          
          const Divider(height: 20),
          
          _ActionButton(
            icon: Icons.delete,
            label: 'Delete Category',
            color: Colors.red,
            onPressed: category.isDefault ? null : onDelete,
            isDestructive: true,
            isDisabled: category.isDefault,
          ),
          
          const SizedBox(height: 10),
          
          // Cancel button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isDestructive = false,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDisabled ? Colors.grey : color;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDestructive && !isDisabled
                ? Colors.red.shade50
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: effectiveColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDisabled 
                        ? Colors.grey.shade400
                        : (isDestructive ? Colors.red.shade600 : null),
                  ),
                ),
              ),
              if (isDisabled) 
                Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey.shade400,
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryListSkeleton extends StatelessWidget {
  const _CategoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => Card(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _CategoryListError extends StatelessWidget {
  const _CategoryListError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryList extends StatelessWidget {
  const _EmptyCategoryList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Categories Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first category to start organizing your expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}