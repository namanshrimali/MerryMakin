import 'package:flutter/material.dart';
import 'package:merrymakin/commons/models/chip_in.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/currency_selector_dropdown.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/factory/app_factory.dart';

class ChipInModal extends StatefulWidget {
  final ChipIn? initialChipIn;
  final Function(ChipIn?) onSave;
  final ProThemeType? themeType;

  const ChipInModal({
    super.key,
    this.initialChipIn,
    required this.onSave,
    this.themeType,
  });

  @override
  State<ChipInModal> createState() => _ChipInModalState();
}

enum PaymentMethod {
  venmo,
  paypal,
  zelle,
  cashapp,
}

class _ChipInModalState extends State<ChipInModal> {
  final _formKey = GlobalKey<FormState>();
  ChipIn? _chipIn;
  final Set<PaymentMethod> _selectedPaymentMethods = {};
  late bool _isChipInEnabled;

  @override
  void initState() {
    super.initState();
    // Initialize chip-in enabled state based on whether there's any existing payment method
    _isChipInEnabled = widget.initialChipIn != null && widget.initialChipIn!.amount != null && widget.initialChipIn!.amount! > 0;
    
    _chipIn = widget.initialChipIn ?? ChipIn(
      currency: AppFactory().cookiesService.locallyStoredCountryCurrency,
    );

    // Initialize selected payment methods based on existing data
    if (widget.initialChipIn?.venmoUserId != null &&
        widget.initialChipIn!.venmoUserId!.isNotEmpty) {
      _selectedPaymentMethods.add(PaymentMethod.venmo);
    }
    if (widget.initialChipIn?.paypalUserId != null &&
        widget.initialChipIn!.paypalUserId!.isNotEmpty) {
      _selectedPaymentMethods.add(PaymentMethod.paypal);
    }
    if (widget.initialChipIn?.zelleUserId != null &&
        widget.initialChipIn!.zelleUserId!.isNotEmpty) {
      _selectedPaymentMethods.add(PaymentMethod.zelle);
    }
    if (widget.initialChipIn?.cashappUserId != null &&
        widget.initialChipIn!.cashappUserId!.isNotEmpty) {
      _selectedPaymentMethods.add(PaymentMethod.cashapp);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleSave() {
    // If chip-in is disabled, save an empty ChipIn object
    if (!_isChipInEnabled) {
      widget.onSave(null);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    widget.onSave(_chipIn);
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  Widget _buildAmountSection(ThemeData theme) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProText(
            'Amount to Chip In',
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),
          ProTextField(
            prefixWidgetPadded: false,
            label: '',
            hintText: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onValidationCallback: _validateAmount,
            onSaved: (value) {
              _chipIn!.amount = double.tryParse(value.toString().trim());
            },
            initialValue: _chipIn!.amount != null && _chipIn!.amount! > 0
                ? _chipIn!.amount!.toStringAsFixed(2)
                : '',
            prefixWidget: SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProCurrencySelectorDropdown(
                  initialCurrency: _chipIn!.currency ?? AppFactory().cookiesService.locallyStoredCountryCurrency,
                  isBig: false,
                  onChanged: (newCurrency) {
                    setState(() {
                      _chipIn!.currency = newCurrency;
                    });
                  }),
              ),
            ),
          ),          
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection(ThemeData theme) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProText(
            'Payment Methods',
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: generalAppLevelPadding / 2),
          ProText(
            'Select payment methods and add your user IDs so guests can chip in',
            textStyle: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),

          // Payment Method Toggle Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentMethodToggle(
                theme: theme,
                method: PaymentMethod.venmo,
                label: 'Venmo',
                icon: Icons.account_balance_wallet,
              ),
              _buildPaymentMethodToggle(
                theme: theme,
                method: PaymentMethod.paypal,
                label: 'PayPal',
                icon: Icons.payment,
              ),
              _buildPaymentMethodToggle(
                theme: theme,
                method: PaymentMethod.zelle,
                label: 'Zelle',
                icon: Icons.account_balance,
              ),
              _buildPaymentMethodToggle(
                theme: theme,
                method: PaymentMethod.cashapp,
                label: 'CashApp',
                icon: Icons.money,
              ),
            ],
          ),

          // Payment Method Input Fields (shown only when selected)
          if (_selectedPaymentMethods.contains(PaymentMethod.venmo)) ...[
            const SizedBox(height: generalAppLevelPadding),
            _buildPaymentMethodField(
              context: context,
              theme: theme,
              label: 'Venmo User ID',
              icon: Icons.account_balance_wallet,
            ),
          ],
          if (_selectedPaymentMethods.contains(PaymentMethod.paypal)) ...[
            const SizedBox(height: generalAppLevelPadding),
            _buildPaymentMethodField(
              context: context,
              theme: theme,
              label: 'PayPal User ID',
              icon: Icons.payment,
            ),
          ],
          if (_selectedPaymentMethods.contains(PaymentMethod.zelle)) ...[
            const SizedBox(height: generalAppLevelPadding),
            _buildPaymentMethodField(
              context: context,
              theme: theme,
              label: 'Zelle User ID',
              icon: Icons.account_balance,
            ),
          ],
          if (_selectedPaymentMethods.contains(PaymentMethod.cashapp)) ...[
            const SizedBox(height: generalAppLevelPadding),
            _buildPaymentMethodField(
              context: context,
              theme: theme,
              label: 'CashApp User ID',
              icon: Icons.money,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodToggle({
    required ThemeData theme,
    required PaymentMethod method,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethods.contains(method);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          ProText(
            label,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedPaymentMethods.add(method);
          } else {
            _selectedPaymentMethods.remove(method);
            // Clear the field when deselected
            switch (method) {
              case PaymentMethod.venmo:
                _chipIn!.venmoUserId = null;
                break;
              case PaymentMethod.paypal:
                _chipIn!.paypalUserId = null;
                break;
              case PaymentMethod.zelle:
                _chipIn!.zelleUserId = null;
                break;
              case PaymentMethod.cashapp:
                _chipIn!.cashappUserId = null;
                break;
            }
          }
        });
      },
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      backgroundColor: Colors.grey.withOpacity(0.1),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : Colors.grey.withOpacity(0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
    );
  }

  Widget _buildPaymentMethodField({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required IconData icon,
  }) {
    return ProTextField(
      key: Key(label),
      label: label,
      autofocus: true,
      hintText: label,
      initialValue: _chipIn!.getPaymentMethodUserId(label),
      onValidationCallback: (value) {
        if ((value == null || value.trim().isEmpty) && !_chipIn!.hasAnyPaymentMethod) {
          return 'Please enter a valid user ID';
        }
        return null;
      },
      onSaved: (value) {
        switch (label) {
          case 'Venmo User ID':
            _chipIn!.venmoUserId = value.toString().trim();
            break;
          case 'PayPal User ID':
            _chipIn!.paypalUserId = value.toString().trim();
            break;
          case 'Zelle User ID':
            _chipIn!.zelleUserId = value.toString().trim();
            break;
          case 'CashApp User ID':
            _chipIn!.cashappUserId = value.toString().trim();
            break;
        }
      },
      prefixWidget: Icon(
        icon,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  Widget _buildChipInToggleSection(ThemeData theme) {
    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProText(
                  'Enable Chip-In',
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                ProText(
                  'Allow guests to contribute towards event expenses',
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isChipInEnabled,
            onChanged: (value) {
              setState(() {
                _isChipInEnabled = value;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ProText(
              'Note: Payments are not verified. Guests self-report payment during RSVP.',
              textStyle: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeType != null
        ? (ProThemes.themes[widget.themeType]?.theme ?? Theme.of(context))
        : Theme.of(context);

    return SafeArea(
      child: Theme(
        data: theme,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Enable/Disable Chip-In Toggle
                _buildChipInToggleSection(theme),
            
                // Only show sections if chip-in is enabled
                if (_isChipInEnabled) ...[
                  const SizedBox(height: generalAppLevelPadding),
            
                  // Amount Section
                  _buildAmountSection(theme),
            
                  const SizedBox(height: generalAppLevelPadding),
            
                  // Payment Methods Section
                  _buildPaymentMethodsSection(theme),
            
                  const SizedBox(height: generalAppLevelPadding),
            
                  // Info Box
                  _buildInfoBox(theme),
                ],
            
                const SizedBox(height: generalAppLevelPadding),
                // Save Button
                ProPrimaryButton(
                  ProText(
                    'Save',
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  onPressed: _handleSave,
                  isBig: true,
                ),
                const SizedBox(height: generalAppLevelPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
