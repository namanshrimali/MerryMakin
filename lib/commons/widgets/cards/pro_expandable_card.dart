import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/cards/pro_card.dart';
import '../../widgets/pro_list_item.dart';

class ProExpandableCard extends StatefulWidget {
  final Widget primaryWidget;
  final Widget trailingWidget;
  final Widget? childWidget;
  const ProExpandableCard(
      {super.key,
      required this.primaryWidget,
      required this.trailingWidget,
      this.childWidget});

  @override
  State<ProExpandableCard> createState() => _ProExpandableCardState();
}

class _ProExpandableCardState extends State<ProExpandableCard> {
  bool _isExpanded = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: generalAppLevelPadding / 2, right: generalAppLevelPadding / 2),
      child: ProCard(
        child: ClipRect(
          child: Column(
            children: [
              ProListItem(
                key: Key("0"),
                title: widget.primaryWidget,
                trailing: Row(
                  children: [
                    widget.trailingWidget,
                    if (widget.childWidget != null)
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    if (widget.childWidget != null) {
                      _isExpanded = !_isExpanded;
                    }
                  });
                },
              ),
              AnimatedCrossFade(
                firstChild: Container(),
                secondChild: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.childWidget),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
