import 'package:flutter/material.dart';

class SettingTiles extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  // final VoidCallback onChanged;
  final ValueChanged<bool> onChanged;
  const SettingTiles({
    super.key,
    required this.icon,
    required this.title,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
            decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10.0)),
            child: Icon(icon)),
        title: Text(title),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
