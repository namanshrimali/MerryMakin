import 'package:flutter/material.dart';

class ProSegmentedButton<T> extends StatelessWidget {
  final Set<T> selected;
  final List<ProButtonSegment<T>> segments;
  final Function(Set<T>) onSelectionChanged;

  const ProSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: segments.map((segment) {
        return selected.any((element) => segment.value == element)
            ? FilledButton.tonal(
                onPressed: () {},
                child: segment.label,
              )
            : TextButton(
                onPressed: () {onSelectionChanged({segment.value});},
                child: segment.label,
              );
      }).toList(),
    );
  }
}

class ProButtonSegment<T> {
  final T value;
  final Icon? icon;
  final Widget label;
  ProButtonSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}
