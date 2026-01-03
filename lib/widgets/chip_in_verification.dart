import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/event_attendee.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:url_launcher/url_launcher.dart';

class ChipInVerification extends StatefulWidget {
  final Event event;
  final Attendee attendee;
  final VoidCallback? onAlreadyPaid;

  const ChipInVerification({
    super.key,
    required this.event,
    required this.attendee,
    this.onAlreadyPaid,
  });

  @override
  State<ChipInVerification> createState() => _ChipInVerificationState();
}

class _ChipInVerificationState extends State<ChipInVerification> {
  bool copied = false;
  int _getTotalAttendeeCount() {
    final plusOnes = widget.attendee.plusOnes?.length ?? 0;
    return 1 + plusOnes;
  }

  double _getTotalAmount() {
    final chipIn = widget.event.chipIn;
    if (chipIn == null || chipIn.amount == null || chipIn.amount! <= 0) {
      return 0.0;
    }
    return _getTotalAttendeeCount() * chipIn.amount!;
  }

  String _getPaymentAppUrl(String paymentMethod, String userId, double amount) {
    final amountStr = amount.toStringAsFixed(2);
    switch (paymentMethod) {
      case 'Venmo':
        // Venmo deep link format: venmo://paycharge?txn=pay&recipients=USERNAME&amount=AMOUNT&note=NOTE
        return 'https://venmo.com/?txn=pay&recipients=$userId&amount=$amountStr&note=${Uri.encodeComponent(widget.event.name)}';
      case 'PayPal':
        // PayPal.me format: https://paypal.me/USERNAME/AMOUNT
        return 'https://paypal.me/$userId/$amountStr';
      case 'Cash App':
        // Cash App deep link format: https://cash.app/\$USERNAME/AMOUNT
        return 'https://cash.app/\$$userId/$amountStr';
      default:
        return '';
    }
  }

  Future<void> _openPaymentApp(
      String paymentMethod, String userId, double amount) async {
    final url = _getPaymentAppUrl(paymentMethod, userId, amount);
    if (url.isEmpty) {
      return;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error opening payment app: $e');
    }
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    String paymentMethod,
    String userId,
    double amount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData icon;

    switch (paymentMethod) {
      case 'Venmo':
        icon = Icons.account_balance_wallet;
        break;
      case 'PayPal':
        icon = Icons.payment;
        break;
      case 'Zelle':
        icon = Icons.account_balance;
        break;
      case 'Cash App':
        icon = Icons.money;
        break;
      default:
        icon = Icons.payment;
    }

    return ProCard(
      elevation: 10,
      surfaceTintColor: Colors.white.withOpacity(0.1),
      child: Row(
        children: [
          // Payment method icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSecondaryContainer,
              size: 28,
            ),
          ),
          const SizedBox(width: generalAppLevelPadding),
          // Payment method name and user ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentMethod,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userId.startsWith('@') ? userId : '@$userId',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Pay button
          // if zelle, show copy button
          if (paymentMethod == 'Zelle')
            FilledButton(
              key: Key(paymentMethod),
              child: ProText(copied ? 'Copied!' : 'Copy', textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                ),),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: userId));
                setState(() {
                  copied = true;
                });
              },
            ),
          if (paymentMethod != 'Zelle')
            FilledButton(
              onPressed: () => _openPaymentApp(paymentMethod, userId, amount),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipIn = widget.event.chipIn;

    if (chipIn == null || chipIn.amount == null || chipIn.amount! <= 0) {
      return const SizedBox.shrink();
    }

    final totalAttendees = _getTotalAttendeeCount();
    final totalAmount = _getTotalAmount();
    final paymentMethods = chipIn.getPaymentMethodLabelsList();

    if (paymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: generalAppLevelPadding),

        // "This event costs" text
        Text(
          'This event costs',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 12),

        // Amount per person
        Text(
          '${chipIn.currency != null ? chipIn.currency!.getCurrencySymbol() : '\$'}${chipIn.amount!.toStringAsFixed(2)} per person',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),

        // Show calculation if there are plus ones
        if (totalAttendees > 1) ...[
          const SizedBox(height: 12),
          ProText(
            '$totalAttendees attendees × ${chipIn.currency != null ? chipIn.currency!.getCurrencySymbol() : '\$'}${chipIn.amount!.toStringAsFixed(2)} = ${chipIn.currency != null ? chipIn.currency!.getCurrencySymbol() : '\$'}${totalAmount.toStringAsFixed(2)}',
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],

        const SizedBox(height: generalAppLevelPadding),

        // "Please pay the host:" text
        Text(
          'Please pay the host:',
          style: TextStyle(
            fontSize: 17,
            color: colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: generalAppLevelPadding * 1.5),

        // Payment method cards
        ...paymentMethods.map((method) {
          final userId = chipIn.getPaymentMethodUserIdViaLabel(method);
          if (userId == null || userId.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildPaymentMethodCard(context, method, userId, totalAmount);
        }).toList(),

        const SizedBox(height: generalAppLevelPadding * 1.5),

        // "I've already paid" link
        TextButton(
          onPressed: widget.onAlreadyPaid ?? () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Text(
            "I've already paid",
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: generalAppLevelPadding),
      ],
    );
  }
}
