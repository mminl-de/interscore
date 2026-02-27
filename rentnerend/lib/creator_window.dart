import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_rentnerend/widgets/color_picker.dart';

import 'md.dart';
import 'ws_client.dart';
import 'widgets/autocomplete_text_field.dart';
import 'lib.dart' as lib;

class PlayerRow extends StatefulWidget {
	final String? defaultName;
	final String? defaultRole;
	final Function(String) onNameChange;
	final Function(String) onRoleChange;

	const PlayerRow({
		super.key,
		this.defaultName,
		this.defaultRole,
		required this.onNameChange,
		required this.onRoleChange
	});

	@override
	State<PlayerRow> createState() => _PlayerRowState();
}

class _PlayerRowState extends State<PlayerRow> {
	@override
	void initState() {
		super.initState();
	}

	@override
	void dispose() {
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Row(children: [
			Expanded(flex: 50, child: AutocompleteTextField(
				list: ["Nordshausen", "Gifhorn"],
				onChange: widget.onNameChange,
				defaultText: widget.defaultName,
				hintText: "Player Name",
			)),
			Expanded(flex: 30, child: AutocompleteTextField(
				list: ["Keeper", "Field"],
				onChange: widget.onRoleChange,
				defaultText: widget.defaultRole,
				hintText: "Role",
			)),
		]);
	}
}

class TeamRow extends StatefulWidget {
	final String? defaultName;
	final bool initialShowPlayers;
	final Function(String) onNameChanged;
	final Function(Color) onColorChanged;
	final index;
	final ValueNotifier<Matchday> mdl;

	const TeamRow({
		super.key,
		this.defaultName,
		required this.initialShowPlayers,
		required this.onNameChanged,
		required this.onColorChanged,
		required this.index,
		required this.mdl,
	});

	@override
	State<TeamRow> createState() => _TeamRowState();
}

class _TeamRowState extends State<TeamRow> {
	late TextEditingController _controller;
	bool _showPlayers = false;
	late ValueNotifier<Matchday> mdl;

	@override
	void initState() {
		super.initState();

		mdl = widget.mdl;
		_controller = TextEditingController(text: widget.defaultName);
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		Matchday md = mdl.value;
		// We have to guard this, because we could be the "empty" Row, where the team does not exist yet. In that case we dont want to draw the Players.
		Team? team;
		if (md.teams.length < widget.index)
			team = md.teams[widget.index];

		return Column(children: [
			Row(children: [
				Expanded(flex: 5, child: lib.ToggleIconButton(
					value: widget.initialShowPlayers,
					onChanged: (v) => setState(() => _showPlayers = v),
				)),
				Expanded(flex: 80, child: AutocompleteTextField(
					list: ["Nordshausen", "Gifhorn"],
					onChange: widget.onNameChanged,
					defaultText: widget.defaultName,
					hintText: "Team Name",
				)),
				Expanded(flex: 15, child:
					ColorPickerButton(
						initialColor: Colors.white,
						onColorChanged: widget.onColorChanged
					)
				),

			]),
			if (_showPlayers && md.teams.length < widget.index)
				for(int i=0; i < team!.players.length; i++)
					PlayerRow(
						defaultName: team.players[i].name,
						onNameChange: (newName) {
							List<Player> newPlayers = List.from(team!.players);
							newPlayers[i] = newPlayers[i].copyWith(name: newName);
							List<Team> newTeams = List.from(md.teams);
							newTeams[widget.index] = team.copyWith(players: newPlayers);
							mdl.value = md.copyWith(teams: newTeams);
						},
						onRoleChange: (newRoleName) {
							List<Player> newPlayers = List.from(team!.players);
							newPlayers[i] = newPlayers[i].copyWith(role: newRoleName);
							List<Team> newTeams = List.from(md.teams);
							newTeams[widget.index] = team.copyWith(players: newPlayers);
							mdl.value = md.copyWith(teams: newTeams);
						},
					),
				PlayerRow(
					onNameChange: (newName) {
						List<Player> newPlayers = List.from(team!.players);
						newPlayers.add(Player(newName, ""));
						List<Team> newTeams = List.from(md.teams);
						newTeams[widget.index] = team.copyWith(players: newPlayers);
						mdl.value = md.copyWith(teams: newTeams);
					},
					onRoleChange: (newRoleName) {
						List<Player> newPlayers = List.from(team!.players);
						newPlayers.add(Player("", newRoleName));
						List<Team> newTeams = List.from(md.teams);
						newTeams[widget.index] = team.copyWith(players: newPlayers);
						mdl.value = md.copyWith(teams: newTeams);
					},
				),
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
					initialShowPlayers: false,
					index: i,
					mdl: mdl
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
				initialShowPlayers: false,
				index: md.teams.length,
				mdl: mdl
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
