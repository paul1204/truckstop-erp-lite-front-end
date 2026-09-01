import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_notifier.dart';

class AddHouseAccountDialog extends StatefulWidget {
  final HouseAccountsNotifier notifier;
  final StyleTokens tokens;

  const AddHouseAccountDialog({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<AddHouseAccountDialog> createState() => _AddHouseAccountDialogState();
}

class _AddHouseAccountDialogState extends State<AddHouseAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final payload = {
      'companyName': _companyController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'creditLimit': double.tryParse(_creditLimitController.text.trim()) ?? 0.0,
    };

    final success = await widget.notifier.addHouseAccount(payload);

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('House account added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to add house account. Please try again.'),
            backgroundColor: widget.tokens.accentSecondary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderStyle = OutlineInputBorder(
      borderSide: BorderSide(color: widget.tokens.border, width: 1),
      borderRadius: BorderRadius.circular(6),
    );
    final focusBorderStyle = OutlineInputBorder(
      borderSide: BorderSide(color: widget.tokens.accent, width: 2),
      borderRadius: BorderRadius.circular(6),
    );
    final labelStyle = TextStyle(
      fontFamily: widget.tokens.sansFont,
      color: widget.tokens.textMain.withOpacity(0.7),
    );

    return AlertDialog(
      title: Text(
        'Add New House Account',
        style: TextStyle(
          fontFamily: widget.tokens.sansFont,
          fontWeight: FontWeight.bold,
          color: widget.tokens.textHeader,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _companyController,
                  enabled: !_isSubmitting,
                  style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    labelStyle: labelStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: focusBorderStyle,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Company Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_isSubmitting,
                  style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: labelStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: focusBorderStyle,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Phone Number is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  enabled: !_isSubmitting,
                  maxLines: 2,
                  style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: labelStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: focusBorderStyle,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _creditLimitController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
                  decoration: InputDecoration(
                    labelText: 'Credit Limit (\$)',
                    labelStyle: labelStyle,
                    enabledBorder: borderStyle,
                    focusedBorder: focusBorderStyle,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Credit Limit is required';
                    }
                    final numLimit = double.tryParse(val.trim());
                    if (numLimit == null || numLimit <= 0) {
                      return 'Enter a valid number greater than 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: widget.tokens.sansFont,
              color: widget.tokens.textMain.withOpacity(0.6),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.tokens.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: widget.tokens.accent.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Add',
                  style: TextStyle(
                    fontFamily: widget.tokens.sansFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
