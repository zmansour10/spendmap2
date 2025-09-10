import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../../shared/widgets/icon_picker.dart';
import '../../../shared/widgets/color_picker.dart';

class CategoryFormDialog extends StatefulWidget {
 const CategoryFormDialog({
   super.key,
   this.initialCategory,
 });

 final CategoryEntity? initialCategory;

 @override
 State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
 final _formKey = GlobalKey<FormState>();
 final _nameController = TextEditingController();
 
 int _selectedIconCode = Icons.category.codePoint;
 int _selectedColorValue = Colors.blue.value;
 
 bool get _isEditing => widget.initialCategory != null;

 @override
 void initState() {
   super.initState();
   if (widget.initialCategory != null) {
     _nameController.text = widget.initialCategory!.name;
     _selectedIconCode = widget.initialCategory!.iconCode;
     _selectedColorValue = widget.initialCategory!.colorValue;
   }
 }

 @override
 void dispose() {
   _nameController.dispose();
   super.dispose();
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(_isEditing ? 'Edit Category' : 'New Category'),
       leading: IconButton(
         onPressed: () => Navigator.pop(context),
         icon: const Icon(Icons.close),
       ),
       actions: [
         TextButton(
           onPressed: _canSave() ? _handleSave : null,
           child: Text(
             _isEditing ? 'Update' : 'Create',
             style: TextStyle(
               color: _canSave() 
                   ? Theme.of(context).primaryColor
                   : Colors.grey,
               fontWeight: FontWeight.w600,
             ),
           ),
         ),
       ],
     ),
     body: Form(
       key: _formKey,
       child: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             // Category preview
             _CategoryPreview(
               name: _nameController.text.isEmpty ? 'Category Name' : _nameController.text,
               iconCode: _selectedIconCode,
               colorValue: _selectedColorValue,
             ),

             const SizedBox(height: 32),

             // Name field
             _SectionCard(
               title: 'Category Name',
               icon: Icons.label,
               child: TextFormField(
                 controller: _nameController,
                 decoration: const InputDecoration(
                   hintText: 'Enter category name...',
                   border: OutlineInputBorder(),
                   counterText: '',
                 ),
                 maxLength: 50,
                 textCapitalization: TextCapitalization.words,
                 validator: _validateName,
                 onChanged: (_) => setState(() {}),
               ),
             ),

             const SizedBox(height: 24),

             // Icon selection
             _SectionCard(
               title: 'Category Icon',
               icon: Icons.palette,
               child: _IconSelectionField(
                 selectedIconCode: _selectedIconCode,
                 selectedColor: Color(_selectedColorValue),
                 onIconSelected: (iconCode) {
                   setState(() {
                     _selectedIconCode = iconCode;
                   });
                 },
               ),
             ),

             const SizedBox(height: 24),

             // Color selection
             _SectionCard(
               title: 'Category Color',
               icon: Icons.color_lens,
               child: _ColorSelectionField(
                 selectedColor: Color(_selectedColorValue),
                 onColorSelected: (color) {
                   setState(() {
                     _selectedColorValue = color.value;
                   });
                 },
               ),
             ),

             const SizedBox(height: 32),

             // Info card
             if (!_isEditing) ...[
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.blue.shade50,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.blue.shade200),
                 ),
                 child: Row(
                   children: [
                     Icon(
                       Icons.info_outline,
                       color: Colors.blue.shade600,
                       size: 20,
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Text(
                         'Categories help organize your expenses. Choose a meaningful name, icon, and color.',
                         style: TextStyle(
                           fontSize: 14,
                           color: Colors.blue.shade700,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 24),
             ],

             // Action buttons
             Row(
               children: [
                 Expanded(
                   child: OutlinedButton(
                     onPressed: () => Navigator.pop(context),
                     style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                     ),
                     child: const Text('Cancel'),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   flex: 2,
                   child: ElevatedButton(
                     onPressed: _canSave() ? _handleSave : null,
                     style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                     ),
                     child: Text(_isEditing ? 'Update Category' : 'Create Category'),
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
     ),
   );
 }

 String? _validateName(String? value) {
   if (value == null || value.trim().isEmpty) {
     return 'Please enter a category name';
   }
   if (value.trim().length < 2) {
     return 'Category name must be at least 2 characters';
   }
   return null;
 }

 bool _canSave() {
   return _nameController.text.trim().isNotEmpty;
 }

 void _handleSave() {
   if (!_formKey.currentState!.validate()) return;

   final category = CategoryEntity(
     id: widget.initialCategory?.id,
     name: _nameController.text.trim(),
     iconCode: _selectedIconCode,
     colorValue: _selectedColorValue,
     isDefault: widget.initialCategory?.isDefault ?? false,
     createdAt: widget.initialCategory?.createdAt,
     updatedAt: DateTime.now(),
   );

   Navigator.pop(context, category);
 }
}

class _CategoryPreview extends StatelessWidget {
 const _CategoryPreview({
   required this.name,
   required this.iconCode,
   required this.colorValue,
 });

 final String name;
 final int iconCode;
 final int colorValue;

 @override
 Widget build(BuildContext context) {
   return Container(
     padding: const EdgeInsets.all(24),
     decoration: BoxDecoration(
       color: Color(colorValue).withOpacity(0.1),
       borderRadius: BorderRadius.circular(20),
       border: Border.all(
         color: Color(colorValue).withOpacity(0.3),
       ),
     ),
     child: Column(
       children: [
         Text(
           'Preview',
           style: Theme.of(context).textTheme.labelMedium?.copyWith(
             color: Colors.grey.shade600,
             fontWeight: FontWeight.w500,
           ),
         ),
         const SizedBox(height: 16),
         Container(
           width: 80,
           height: 80,
           decoration: BoxDecoration(
             color: Color(colorValue).withOpacity(0.2),
             borderRadius: BorderRadius.circular(40),
           ),
           child: Icon(
             IconData(iconCode, fontFamily: 'MaterialIcons'),
             color: Color(colorValue),
             size: 40,
           ),
         ),
         const SizedBox(height: 16),
         Text(
           name,
           style: Theme.of(context).textTheme.titleLarge?.copyWith(
             fontWeight: FontWeight.bold,
             color: Color(colorValue),
           ),
           textAlign: TextAlign.center,
         ),
       ],
     ),
   );
 }
}

class _SectionCard extends StatelessWidget {
 const _SectionCard({
   required this.title,
   required this.icon,
   required this.child,
 });

 final String title;
 final IconData icon;
 final Widget child;

 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Row(
         children: [
           Icon(
             icon,
             size: 20,
             color: Theme.of(context).primaryColor,
           ),
           const SizedBox(width: 8),
           Text(
             title,
             style: Theme.of(context).textTheme.titleMedium?.copyWith(
               fontWeight: FontWeight.w600,
             ),
           ),
         ],
       ),
       const SizedBox(height: 12),
       child,
     ],
   );
 }
}

class _IconSelectionField extends StatelessWidget {
 const _IconSelectionField({
   required this.selectedIconCode,
   required this.selectedColor,
   required this.onIconSelected,
 });

 final int selectedIconCode;
 final Color selectedColor;
 final ValueChanged<int> onIconSelected;

 @override
 Widget build(BuildContext context) {
   return InkWell(
     onTap: () => _showIconPicker(context),
     borderRadius: BorderRadius.circular(8),
     child: Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade300),
         borderRadius: BorderRadius.circular(8),
       ),
       child: Row(
         children: [
           Container(
             width: 48,
             height: 48,
             decoration: BoxDecoration(
               color: selectedColor.withOpacity(0.2),
               borderRadius: BorderRadius.circular(24),
             ),
             child: Icon(
               IconData(selectedIconCode, fontFamily: 'MaterialIcons'),
               color: selectedColor,
               size: 24,
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Text(
               'Tap to choose icon',
               style: Theme.of(context).textTheme.bodyLarge,
             ),
           ),
           Icon(
             Icons.arrow_forward_ios,
             size: 16,
             color: Colors.grey.shade400,
           ),
         ],
       ),
     ),
   );
 }

 Future<void> _showIconPicker(BuildContext context) async {
   final result = await showDialog<int>(
     context: context,
     builder: (context) => IconPickerDialog(
       selectedIconCode: selectedIconCode,
     ),
   );

   if (result != null) {
     onIconSelected(result);
   }
 }
}

class _ColorSelectionField extends StatelessWidget {
 const _ColorSelectionField({
   required this.selectedColor,
   required this.onColorSelected,
 });

 final Color selectedColor;
 final ValueChanged<Color> onColorSelected;

 @override
 Widget build(BuildContext context) {
   return InkWell(
     onTap: () => _showColorPicker(context),
     borderRadius: BorderRadius.circular(8),
     child: Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         border: Border.all(color: Colors.grey.shade300),
         borderRadius: BorderRadius.circular(8),
       ),
       child: Row(
         children: [
           Container(
             width: 48,
             height: 48,
             decoration: BoxDecoration(
               color: selectedColor,
               borderRadius: BorderRadius.circular(24),
               border: Border.all(
                 color: Colors.grey.shade300,
                 width: 2,
               ),
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Selected Color',
                   style: Theme.of(context).textTheme.bodyLarge,
                 ),
                 Text(
                   '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                   style: TextStyle(
                     fontSize: 12,
                     color: Colors.grey.shade600,
                     fontFamily: 'monospace',
                   ),
                 ),
               ],
             ),
           ),
           Icon(
             Icons.arrow_forward_ios,
             size: 16,
             color: Colors.grey.shade400,
           ),
         ],
       ),
     ),
   );
 }

 Future<void> _showColorPicker(BuildContext context) async {
   final result = await showDialog<Color>(
     context: context,
     builder: (context) => ColorPickerDialog(
       selectedColor: selectedColor,
     ),
   );

   if (result != null) {
     onColorSelected(result);
   }
 }
}