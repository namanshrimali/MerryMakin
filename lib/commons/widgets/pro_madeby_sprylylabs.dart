import 'package:flutter/material.dart';
import './pro_text.dart';

class ProMadeBySprylyLabs extends StatelessWidget {
  const ProMadeBySprylyLabs({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [ProText('Made with (•̀ᴗ•́)و ̑̑'), ProText('From Spryly Labs')],
    );
  }
}
