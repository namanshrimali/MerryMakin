import 'package:flutter/material.dart';
import '../widgets/pro_text.dart';

import '../widgets/pro_text_field.dart';
import '../widgets/pro_list_item.dart';
import '../models/country_currency.dart';
import '../models/goal.dart';

import '../utils/math.dart';

class AllocationTile extends StatefulWidget {
  final Goal goal;
  final double totalAmount;
  final CountryCurrency countryCurrency;
  final Function(double, Goal) onUpdateAllocation;

  const AllocationTile({
    super.key,
    required this.goal,
    required this.totalAmount,
    required this.onUpdateAllocation,
    required this.countryCurrency,
  });

  @override
  State<AllocationTile> createState() => _AllocationTileState();
}

class _AllocationTileState extends State<AllocationTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.goal.incomeAllocationPercentage.toString() == "0.0"
        ? TextEditingController()
        : TextEditingController(
            text: widget.goal.incomeAllocationPercentage.toString());
  }

  Widget buildAllocationTile(BuildContext context) {
    return ProListItem(
      key: Key(widget.goal.id!.toString()),
      title: ProText( widget.goal.title),
      subtitle: ProText(
              "${widget.countryCurrency.getCurrencySymbol()}${formatNumber(widget.goal.incomeAllocationPercentage * widget.totalAmount / 100)}/mo"),
      trailing: SizedBox(
        width: 70, // Adjust this width as needed
        child: ProTextField(
          textEditingController: _controller,
          keyboardType: TextInputType.number,
          hintText: "0",
          onChanged: (text) {
            try {
              double incomeAllocationPercentage =
                  text.toString().isEmpty ? 0 : double.parse(text);
              widget.onUpdateAllocation(
                  incomeAllocationPercentage, widget.goal);
            } catch (_) {}
          },
          suffixWidget: const Text("%"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildAllocationTile(context);
  }
}

