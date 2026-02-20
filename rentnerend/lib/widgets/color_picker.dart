import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  const ColorPickerButton({
    required this.initialColor,
    required this.onColorChanged,
    super.key,
  });

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  late Color _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialColor;
  }

  Future<void> _openPicker() async {
    Color temp = _current;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            enableAlpha: false, // true if you want alpha
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _current = temp);
              widget.onColorChanged(_current);
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openPicker,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundColor: _current, radius: 14),
          const SizedBox(width: 8),
          const Text('Choose color'),
        ],
      ),
    );
  }
}
