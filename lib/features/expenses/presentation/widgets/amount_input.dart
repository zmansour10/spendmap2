import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/utils/currency_formatter.dart';

class AmountInput extends StatefulWidget {
  const AmountInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.hasError = false,
    this.errorText,
    this.enabled = true,
    this.autoFocus = false,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final bool hasError;
  final String? errorText;
  final bool enabled;
  final bool autoFocus;

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _updateControllerText();
    
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(AmountInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _updateControllerText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateControllerText() {
    final text = widget.value == 0.0 ? '' : widget.value.toStringAsFixed(2);
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  void _handleFocusChange() {
    setState(() {
      _isEditing = _focusNode.hasFocus;
    });
    
    if (!_focusNode.hasFocus) {
      // Format the text when focus is lost
      _formatAndUpdate();
    }
  }

  void _formatAndUpdate() {
    final text = _controller.text.replaceAll(RegExp(r'[^\d.]'), '');
    final value = double.tryParse(text) ?? 0.0;
    
    widget.onChanged(value);
    _updateControllerText();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.hasError 
                  ? Colors.red.shade300
                  : _focusNode.hasFocus 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            color: widget.enabled 
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.grey.shade100,
          ),
          child: Row(
            children: [
              // Currency symbol
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '\$',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: widget.hasError 
                        ? Colors.red.shade600
                        : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Amount input
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autoFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    _AmountInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    hintStyle: TextStyle(
                      fontSize: 24,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.hasError 
                        ? Colors.red.shade600
                        : null,
                  ),
                  textAlign: TextAlign.left,
                  onChanged: (text) {
                    final cleanText = text.replaceAll(RegExp(r'[^\d.]'), '');
                    final value = double.tryParse(cleanText) ?? 0.0;
                    widget.onChanged(value);
                  },
                ),
              ),
              
              // Clear button
              if (_controller.text.isNotEmpty && widget.enabled)
                IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged(0.0);
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        
        // Error text
        if (widget.hasError && widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ],
        
        // Helper text showing formatted amount
        if (!_isEditing && widget.value > 0 && !widget.hasError) ...[
          const SizedBox(height: 6),
          Text(
            'Amount: ${CurrencyFormatter.format(widget.value)}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty string
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-digit or non-decimal characters
    String newText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Ensure only one decimal point
    int decimalCount = newText.split('.').length - 1;
    if (decimalCount > 1) {
      return oldValue;
    }
    
    // Limit to 2 decimal places
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      if (parts.length == 2 && parts[1].length > 2) {
        newText = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }
    
    // Limit total value to prevent overflow
    final value = double.tryParse(newText);
    if (value != null && value > 999999.99) {
      return oldValue;
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}