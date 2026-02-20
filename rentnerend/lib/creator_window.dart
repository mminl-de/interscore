import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_rentnerend/widgets/color_picker.dart';

import 'md.dart';
import 'ws_client.dart';
import 'lib.dart' as lib;


class TeamRow extends StatefulWidget {
	final String? defaultName;
	final bool initialShowPlayers;
	final Function(String) onNameChanged;
	final Function(Color) onColorChanged;

	const TeamRow({
		super.key,
		this.defaultName,
		required this.initialShowPlayers,
		required this.onNameChanged,
		required this.onColorChanged,
	});

	@override
	State<TeamRow> createState() => _TeamRowState();
}

class _TeamRowState extends State<TeamRow> {
	late TextEditingController _controller;
	bool _showPlayers = false;

	@override
	void initState() {
		super.initState();
		_controller = TextEditingController(text: widget.defaultName);
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Column(children: [
			Row(children: [
				Expanded(flex: 5, child: lib.ToggleIconButton(
					value: widget.initialShowPlayers,
					onChanged: (v) => setState(() => _showPlayers = v),
				)),
				Expanded(flex: 80, child: Autocomplete<String>(
					optionsBuilder: (TextEditingValue textEditingValue) {
						const List<String> opts = ["TEAM A"];
						if (textEditingValue.text == '')
							return const Iterable<String>.empty();
						return opts.where((String opt) {
							return opt.contains(textEditingValue.text);
						});
					},
					onSelected: (String selection) {
						widget.onNameChanged(selection);
					},
					fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
						return TextField(
							controller: controller,
							focusNode: focusNode,
							textInputAction: TextInputAction.next,
							onSubmitted: (String value) => widget.onNameChanged(value),
							decoration: const InputDecoration(
								border: OutlineInputBorder(),
								hintText: "Team Name",
								//suffixIcon: Icon(Icons.arrow_drop_down),
							),
						);
					}
				)),
				Expanded(flex: 15, child:
					ColorPickerButton(
						initialColor: Colors.white,
						onColorChanged: widget.onColorChanged
					)
				),

			]),
			//if (_showPlayers)
			//	for(int i=0; i < md.teams.length; i++)
			//		TeamRow(
			//			defaultName: md.teams[i].name,
			//			onNameChanged: (newName) {
			//				List<Team> newTeams = List.from(md.teams);
			//				newTeams[i] = md.teams[i].copyWith(name: newName);
			//				mdl.value = md.copyWith(teams: newTeams);
			//			},
			//			onColorChanged: (color) {
			//				List<Team> newTeams = List.from(md.teams);
			//				newTeams[i] = md.teams[i].copyWith(color: color.toHexString(includeHashSign: true));
			//				mdl.value = md.copyWith(teams: newTeams);
			//			},
			//			initialShowPlayers: false
			//		),
			//	TeamRow(
			//		onNameChanged: (newName) {
			//			if (newName.trim().isNotEmpty) {
			//				List<Team> newTeams = List.from(md.teams);
			//				newTeams.add(Team(newName, "", "#ffffff", []));
			//				mdl.value = md.copyWith(teams: newTeams);
			//			}
			//		},
			//		onColorChanged: (color) {
			//			List<Team> newTeams = List.from(md.teams);
			//			newTeams.add(Team("", "", color.toHexString(includeHashSign: true), []));
			//			mdl.value = md.copyWith(teams: newTeams);
			//		},
			//		initialShowPlayers: false
			//	)
		]);
	}
}


class CreatorWindow extends StatefulWidget {
	const CreatorWindow({super.key});

	@override
	State<CreatorWindow> createState() => _CreatorWindowState();
}

class _CreatorWindowState extends State<CreatorWindow> {
	late ValueNotifier<Matchday> mdl;

	@override
	void initState() {
		super.initState();

		final Matchday md = Matchday(Meta(), [], [], [], []);
		mdl = ValueNotifier(md);
	}

	@override
	void dispose() {
		mdl.dispose();

		super.dispose();
	}

	//final textGroup = AutoSizeGroup();

	Widget generalBlock(Matchday md) {
		return SizedBox.shrink();
	}

	Widget teamsBlock(Matchday md) {
		return Column(children: [
			for(int i=0; i < md.teams.length; i++)
				TeamRow(
					defaultName: md.teams[i].name,
					onNameChanged: (newName) {
						List<Team> newTeams = List.from(md.teams);
						newTeams[i] = md.teams[i].copyWith(name: newName);
						mdl.value = md.copyWith(teams: newTeams);
					},
					onColorChanged: (color) {
						List<Team> newTeams = List.from(md.teams);
						newTeams[i] = md.teams[i].copyWith(color: color.toHexString(includeHashSign: true));
						mdl.value = md.copyWith(teams: newTeams);
					},
					initialShowPlayers: false
				),
			TeamRow(
				onNameChanged: (newName) {
					if (newName.trim().isNotEmpty) {
						List<Team> newTeams = List.from(md.teams);
						newTeams.add(Team(newName, "", "#ffffff", []));
						mdl.value = md.copyWith(teams: newTeams);
					}
				},
				onColorChanged: (color) {
					List<Team> newTeams = List.from(md.teams);
					newTeams.add(Team("", "", color.toHexString(includeHashSign: true), []));
					mdl.value = md.copyWith(teams: newTeams);
				},
				initialShowPlayers: false
			)
		]);
	}

	Widget gamesBlock(Matchday md) {
		return SizedBox.shrink();
	}

	@override
	Widget build(BuildContext context) {
		//final secondBgColor = Theme.of(context).scaffoldBackgroundColor;

		return PopScope(child:
			Scaffold(body:
				//body: SingleChildScrollView(child:
					ValueListenableBuilder<Matchday>(
						valueListenable: mdl,
						builder: (context, md, _) {
							return Column(
								//mainAxisSize: MainAxisSize.min,
								spacing: 20,
								children: [
									//generalBlock(md),
									teamsBlock(md),
									//gamesBlock(md)
								]
							);
						}
					)
				//)
			)
		);
	}
}
