import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';

class CategorySelector extends ConsumerWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.hasError = false,
    this.errorText,
    this.enabled = true,
  });

  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final bool hasError;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategories = ref.watch(activeCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        activeCategories.when(
          data: (categories) => _buildCategoryGrid(context, categories),
          loading: () => const _CategorySelectorSkeleton(),
          error: (error, stack) => _CategorySelectorError(
            error: error.toString(),
            onRetry: () => ref.invalidate(activeCategoriesProvider),
          ),
        ),
        
        if (hasError && errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<CategoryEntity> categories) {
    if (categories.isEmpty) {
      return _EmptyCategoriesWidget(
        onCreateCategory: () => _showCreateCategoryDialog(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected category display (if any)
        if (selectedCategoryId != null) ...[
          _SelectedCategoryDisplay(
            categoryId: selectedCategoryId!,
            onClear: () => onCategorySelected(null),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
        ],

        // Category grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length + 1, // +1 for "Add Category" button
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return _AddCategoryButton(
                onTap: () => _showCreateCategoryDialog(context),
              );
            }

            final category = categories[index];
            final isSelected = selectedCategoryId == category.id;

            return _CategoryOption(
              category: category,
              isSelected: isSelected,
              onTap: enabled ? () => onCategorySelected(category.id) : null,
            );
          },
        ),
      ],
    );
  }

  void _showCreateCategoryDialog(BuildContext context) {
    // TODO: Navigate to category creation screen or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category creation will be implemented in the next phase'),
      ),
    );
  }
}

class _SelectedCategoryDisplay extends ConsumerWidget {
  const _SelectedCategoryDisplay({
    required this.categoryId,
    required this.onClear,
  });

  final int categoryId;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(categoryId));

    return category.when(
      data: (cat) {
        if (cat == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(cat.colorValue).withOpacity(0.1),
            border: Border.all(
              color: Color(cat.colorValue).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                color: Color(cat.colorValue),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 60,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected 
                ? Color(category.colorValue).withOpacity(0.2)
                : Colors.grey.shade50,
            border: Border.all(
              color: isSelected 
                  ? Color(category.colorValue)
                  : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                color: isSelected 
                    ? Color(category.colorValue)
                    : Colors.grey.shade600,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? Color(category.colorValue)
                      : Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.check_circle,
                  color: Color(category.colorValue),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCategoryButton extends StatelessWidget {
  const _AddCategoryButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Add\nCategory',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCategoriesWidget extends StatelessWidget {
  const _EmptyCategoriesWidget({
    required this.onCreateCategory,
  });

  final VoidCallback onCreateCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first category to start organizing your expenses.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreateCategory,
            icon: const Icon(Icons.add),
            label: const Text('Create Category'),
          ),
        ],
      ),
    );
  }
}

class _CategorySelectorSkeleton extends StatelessWidget {
  const _CategorySelectorSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _CategorySelectorError extends StatelessWidget {
  const _CategorySelectorError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}