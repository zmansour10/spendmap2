import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    super.key,
    this.selectedColor,
  });

  final Color? selectedColor;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color? _selectedColor;

  static const List<Color> _predefinedColors = [
    // Primary colors
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    
    // Darker variants
    Color(0xFF8B0000), // Dark Red
    Color(0xFF800080), // Purple
    Color(0xFF000080), // Navy
    Color(0xFF008B8B), // Dark Cyan
    Color(0xFF006400), // Dark Green
    Color(0xFF8B4513), // Saddle Brown
    Color(0xFF2F4F4F), // Dark Slate Grey
    Color(0xFF1C1C1C), // Dark Grey
    
    // Lighter variants
    Color(0xFFFFB6C1), // Light Pink
    Color(0xFFDDA0DD), // Plum
    Color(0xFF87CEEB), // Sky Blue
    Color(0xFF98FB98), // Pale Green
    Color(0xFFFFE4B5), // Moccasin
    Color(0xFFF0E68C), // Khaki
    Color(0xFFD3D3D3), // Light Grey
    
    // Special colors
    Color(0xFF4CAF50), // Material Green
    Color(0xFF2196F3), // Material Blue
    Color(0xFFFF9800), // Material Orange
    Color(0xFF9C27B0), // Material Purple
    Color(0xFF00BCD4), // Material Cyan
    Color(0xFFE91E63), // Material Pink
    Color(0xFF795548), // Material Brown
    Color(0xFF607D8B), // Material Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose Color',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _getContrastColor(_selectedColor!),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close, 
                      color: _getContrastColor(_selectedColor!),
                    ),
                  ),
                ],
              ),
            ),

            // Selected color info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#${_selectedColor!.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            // Color grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _predefinedColors.length,
                  itemBuilder: (context, index) {
                    final color = _predefinedColors[index];
                    final isSelected = _selectedColor?.value == color.value;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.black87
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: _getContrastColor(color),
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
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
                      onPressed: () => Navigator.pop(context, _selectedColor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedColor,
                        foregroundColor: _getContrastColor(_selectedColor!),
                      ),
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

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need dark or light text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Simple color picker widget for inline use
class InlineColorPicker extends StatelessWidget {
 const InlineColorPicker({
   super.key,
   required this.selectedColor,
   required this.onColorSelected,
   this.colors,
   this.crossAxisCount = 8,
 });

 final Color selectedColor;
 final ValueChanged<Color> onColorSelected;
 final List<Color>? colors;
 final int crossAxisCount;

 static const List<Color> _defaultColors = [
   Colors.red,
   Colors.pink,
   Colors.purple,
   Colors.deepPurple,
   Colors.indigo,
   Colors.blue,
   Colors.lightBlue,
   Colors.cyan,
   Colors.teal,
   Colors.green,
   Colors.lightGreen,
   Colors.lime,
   Colors.yellow,
   Colors.amber,
   Colors.orange,
   Colors.deepOrange,
 ];

 @override
 Widget build(BuildContext context) {
   final colorList = colors ?? _defaultColors;

   return GridView.builder(
     shrinkWrap: true,
     physics: const NeverScrollableScrollPhysics(),
     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
       crossAxisCount: crossAxisCount,
       childAspectRatio: 1,
       crossAxisSpacing: 8,
       mainAxisSpacing: 8,
     ),
     itemCount: colorList.length,
     itemBuilder: (context, index) {
       final color = colorList[index];
       final isSelected = selectedColor.value == color.value;

       return InkWell(
         onTap: () => onColorSelected(color),
         borderRadius: BorderRadius.circular(20),
         child: Container(
           decoration: BoxDecoration(
             color: color,
             borderRadius: BorderRadius.circular(20),
             border: Border.all(
               color: isSelected ? Colors.black87 : Colors.grey.shade300,
               width: isSelected ? 2 : 1,
             ),
           ),
           child: isSelected
               ? Icon(
                   Icons.check,
                   color: _getContrastColor(color),
                   size: 16,
                 )
               : null,
         ),
       );
     },
   );
 }

 Color _getContrastColor(Color color) {
   final luminance = color.computeLuminance();
   return luminance > 0.5 ? Colors.black87 : Colors.white;
 }
}

/// Color swatch picker for material design colors
class MaterialColorPicker extends StatefulWidget {
 const MaterialColorPicker({
   super.key,
   required this.selectedColor,
   required this.onColorSelected,
 });

 final Color selectedColor;
 final ValueChanged<Color> onColorSelected;

 @override
 State<MaterialColorPicker> createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
 MaterialColor? _selectedSwatch;
 int _selectedShade = 500;

 static const List<MaterialColor> _materialColors = [
   Colors.red,
   Colors.pink,
   Colors.purple,
   Colors.deepPurple,
   Colors.indigo,
   Colors.blue,
   Colors.lightBlue,
   Colors.cyan,
   Colors.teal,
   Colors.green,
   Colors.lightGreen,
   Colors.lime,
   Colors.yellow,
   Colors.amber,
   Colors.orange,
   Colors.deepOrange,
   Colors.brown,
   Colors.grey,
   Colors.blueGrey,
 ];

 static const List<int> _shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

 @override
 void initState() {
   super.initState();
   _findSelectedSwatch();
 }

 void _findSelectedSwatch() {
   for (final swatch in _materialColors) {
     for (final shade in _shades) {
       if (swatch[shade]?.value == widget.selectedColor.value) {
         _selectedSwatch = swatch;
         _selectedShade = shade;
         return;
       }
     }
   }
   _selectedSwatch = Colors.blue;
   _selectedShade = 500;
 }

 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Color swatch selector
       Text(
         'Color',
         style: Theme.of(context).textTheme.titleSmall?.copyWith(
           fontWeight: FontWeight.w600,
         ),
       ),
       const SizedBox(height: 8),
       SizedBox(
         height: 40,
         child: ListView.builder(
           scrollDirection: Axis.horizontal,
           itemCount: _materialColors.length,
           itemBuilder: (context, index) {
             final swatch = _materialColors[index];
             final isSelected = _selectedSwatch == swatch;

             return Padding(
               padding: const EdgeInsets.only(right: 8),
               child: InkWell(
                 onTap: () {
                   setState(() {
                     _selectedSwatch = swatch;
                   });
                   widget.onColorSelected(swatch[_selectedShade]!);
                 },
                 borderRadius: BorderRadius.circular(20),
                 child: Container(
                   width: 40,
                   height: 40,
                   decoration: BoxDecoration(
                     color: swatch[500],
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(
                       color: isSelected ? Colors.black87 : Colors.grey.shade300,
                       width: isSelected ? 2 : 1,
                     ),
                   ),
                   child: isSelected
                       ? Icon(
                           Icons.check,
                           color: _getContrastColor(swatch[500]!),
                           size: 16,
                         )
                       : null,
                 ),
               ),
             );
           },
         ),
       ),

       const SizedBox(height: 16),

       // Shade selector
       if (_selectedSwatch != null) ...[
         Text(
           'Shade',
           style: Theme.of(context).textTheme.titleSmall?.copyWith(
             fontWeight: FontWeight.w600,
           ),
         ),
         const SizedBox(height: 8),
         Wrap(
           spacing: 8,
           runSpacing: 8,
           children: _shades.map((shade) {
             final color = _selectedSwatch![shade];
             if (color == null) return const SizedBox.shrink();
             
             final isSelected = _selectedShade == shade;

             return InkWell(
               onTap: () {
                 setState(() {
                   _selectedShade = shade;
                 });
                 widget.onColorSelected(color);
               },
               borderRadius: BorderRadius.circular(16),
               child: Container(
                 width: 32,
                 height: 32,
                 decoration: BoxDecoration(
                   color: color,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(
                     color: isSelected ? Colors.black87 : Colors.grey.shade300,
                     width: isSelected ? 2 : 1,
                   ),
                 ),
                 child: isSelected
                     ? Icon(
                         Icons.check,
                         color: _getContrastColor(color),
                         size: 12,
                       )
                     : null,
               ),
             );
           }).toList(),
         ),
       ],
     ],
   );
 }

 Color _getContrastColor(Color color) {
   final luminance = color.computeLuminance();
   return luminance > 0.5 ? Colors.black87 : Colors.white;
 }
}