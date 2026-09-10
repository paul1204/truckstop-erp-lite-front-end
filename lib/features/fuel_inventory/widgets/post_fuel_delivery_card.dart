import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/fuel_inventory_notifier.dart';

class PostFuelDeliveryCard extends StatefulWidget {
  final FuelInventoryNotifier notifier;
  final StyleTokens tokens;

  const PostFuelDeliveryCard({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<PostFuelDeliveryCard> createState() => _PostFuelDeliveryCardState();
}

class _PostFuelDeliveryCardState extends State<PostFuelDeliveryCard> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _deliveryIdController = TextEditingController();
  final _dateController = TextEditingController();

  final _dieselGalsController = TextEditingController();
  final _dieselPriceController = TextEditingController();

  final _regGalsController = TextEditingController();
  final _regPriceController = TextEditingController();

  final _premGalsController = TextEditingController();
  final _premPriceController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initDefaults();
  }

  String _formatVisualDate(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    return '$mm/$dd/$yyyy';
  }

  String _toBackendDate(String visualDate) {
    final trimmed = visualDate.trim();
    final parts = trimmed.split(RegExp(r'[/.-]'));
    if (parts.length == 3) {
      if (parts[0].length <= 2 && parts[2].length == 4) {
        // MM/DD/YYYY -> YYYY-MM-DD
        final mm = parts[0].padLeft(2, '0');
        final dd = parts[1].padLeft(2, '0');
        final yyyy = parts[2];
        return '$yyyy-$mm-$dd';
      } else if (parts[0].length == 4) {
        // Already YYYY-MM-DD
        return '${parts[0]}-${parts[1].padLeft(2, '0')}-${parts[2].padLeft(2, '0')}';
      }
    }
    return trimmed.isNotEmpty ? trimmed : DateTime.now().toString().substring(0, 10);
  }

  void _initDefaults() {
    _companyController.clear(); // Left blank for user entry
    _deliveryIdController.text = 'BOL-84920';
    _dateController.text = _formatVisualDate(DateTime.now());
    _dieselGalsController.text = '345';
    _dieselPriceController.text = '3.49';
    _regGalsController.text = '1000';
    _regPriceController.text = '3.49';
    _premGalsController.text = '123';
    _premPriceController.text = '2.59';
  }

  @override
  void dispose() {
    _companyController.dispose();
    _deliveryIdController.dispose();
    _dateController.dispose();
    _dieselGalsController.dispose();
    _dieselPriceController.dispose();
    _regGalsController.dispose();
    _regPriceController.dispose();
    _premGalsController.dispose();
    _premPriceController.dispose();
    super.dispose();
  }

  Future<void> _submitDelivery() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Company Name and Delivery ID before posting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final orders = <String, Map<String, double>>{
      'Diesel': {
        'gallons': double.tryParse(_dieselGalsController.text) ?? 0.0,
        'price': double.tryParse(_dieselPriceController.text) ?? 0.0,
      },
      'Regular Unleaded (87)': {
        'gallons': double.tryParse(_regGalsController.text) ?? 0.0,
        'price': double.tryParse(_regPriceController.text) ?? 0.0,
      },
      'Premium Unleaded (93)': {
        'gallons': double.tryParse(_premGalsController.text) ?? 0.0,
        'price': double.tryParse(_premPriceController.text) ?? 0.0,
      },
    };

    final backendDate = _toBackendDate(_dateController.text);

    final (success, errorMsg) = await widget.notifier.postDelivery(
      _companyController.text.trim(),
      _deliveryIdController.text.trim(),
      backendDate,
      orders,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      _companyController.clear();
      _deliveryIdController.clear();
      _dateController.text = _formatVisualDate(DateTime.now());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fuel delivery posted and reconciled successfully!'),
          backgroundColor: widget.tokens.accent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg ?? 'Failed to post delivery: Backend unavailable.'),
          backgroundColor: widget.tokens.accentSecondary,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isNumeric = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: widget.tokens.sansFont,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: widget.tokens.textHeader,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: TextStyle(
            fontFamily: widget.tokens.sansFont,
            fontSize: 12,
            color: widget.tokens.textHeader,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: widget.tokens.sansFont,
              fontSize: 12,
              color: widget.tokens.textMain.withOpacity(0.4),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            fillColor: widget.tokens.background,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: widget.tokens.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: widget.tokens.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: widget.tokens.accent),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    // Guarantee default demo values are populated even if existing widget state was empty
    if (_dieselGalsController.text.isEmpty && _dieselPriceController.text.isEmpty) {
      _initDefaults();
    }

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Post Fuel Delivery (BOL Drop)',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: tokens.textHeader,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _initDefaults()),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tokens.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: tokens.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 11, color: tokens.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Demo Values',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: tokens.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.local_shipping, size: 16, color: tokens.accent),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Company Name & Delivery ID
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: _companyController,
                    label: 'Company Name',
                    hint: 'Enter Company',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _deliveryIdController,
                    label: 'Delivery ID',
                    hint: 'BOL-XXXXX',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Date
            _buildTextField(
              controller: _dateController,
              label: 'Delivery Date (MM/DD/YYYY)',
              hint: 'MM/DD/YYYY',
            ),
            const SizedBox(height: 12),
            Divider(color: tokens.border.withOpacity(0.4), height: 1),
            const SizedBox(height: 12),

            // Diesel gallons & price
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _dieselGalsController,
                    label: 'Diesel (gal)',
                    isNumeric: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _dieselPriceController,
                    label: 'Price per gallon',
                    hint: '\$/gal',
                    isNumeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Regular 87 gallons & price
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _regGalsController,
                    label: 'Regular 87 (gal)',
                    isNumeric: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _regPriceController,
                    label: 'Price per gallon',
                    hint: '\$/gal',
                    isNumeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Premium 93 gallons & price
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _premGalsController,
                    label: 'Premium 93 (gal)',
                    isNumeric: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: _premPriceController,
                    label: 'Price per gallon',
                    hint: '\$/gal',
                    isNumeric: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.accent,
                  foregroundColor: tokens.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Post Fuel Delivery',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
