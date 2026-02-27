import 'package:flutter/material.dart';

class AutocompleteTextField extends StatefulWidget {
	final String? defaultText;
	final String? hintText;
	final Function(String) onChange;
	final List<String> list;

	const AutocompleteTextField({
		super.key,
		this.defaultText,
		this.hintText,
		required this.onChange,
		required this.list,
	});

	@override
	State<AutocompleteTextField> createState() => _TeamRowState();
}

class _TeamRowState extends State<AutocompleteTextField> {
	late TextEditingController _controller;

	@override
	void initState() {
		super.initState();
		_controller = TextEditingController(text: widget.defaultText);
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Autocomplete<String>(
			initialValue: TextEditingValue(text: widget.defaultText ?? ""),
			optionsBuilder: (TextEditingValue textEditingValue) {
				if (textEditingValue.text == '')
					return const Iterable<String>.empty();
				return widget.list.where((String opt) {
					return opt.contains(textEditingValue.text);
				});
			},
			onSelected: (String selection) {
				widget.onChange(selection);
			},
			fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
				return TextField(
					controller: controller,
					focusNode: focusNode,
					textInputAction: TextInputAction.next,
					onSubmitted: (String value) => widget.onChange(value),
					decoration: InputDecoration(
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(25.0),
						),
						hintText: widget.hintText,
					),
				);
			}
		);
	}
}
