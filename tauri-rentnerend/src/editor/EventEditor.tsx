import { createSignal, onCleanup, onMount } from "solid-js";
import { createStore } from "solid-js/store";
import { open } from "@tauri-apps/plugin-dialog";
import { useNavigate } from "@solidjs/router";

import Form from "./Form";
import { Role, role_id } from "./Role";
import { Player } from "./Player";
import { Team, TeamProps, team_id } from "./Team";
import { Game, GameProps } from "./Game";

import "../root.css";
import "./EventEditor.css";

// Truncates and converts casing of `input` into snake_case to generate a
// possible basename for a tournament file path.
function generate_basename(input: string): string {
	// TODO make it handle input present in tourn_path
	if (input === "") return "tournament.json";
	if (input.length > 32) input = input.slice(0, 32);
	return input.toLowerCase().replace(/\s|\./g, "_") + ".json";
}

// TODO handle: deleting a team resets affected games
// TODO handle: deleting a role resets the roles of those players
// TODO CHECK there is a dummy role with index 0 in the role list
// TODO FINAL HANDLE checking if all input are correct:
//     all players have roles
//     all entries distinct (collisions should be forbidden either way)

// TODO MOVE to their respective files
export const [roles, set_roles] = createStore<Record<string, string>>({});
export const [teams, set_teams] = createStore<Record<string, TeamProps>>({});
export const [selected_role, set_selected_role] = createSignal<string | null>(null);
const [games, set_games] = createSignal<GameProps[]>([]);
export const [selected_team, set_selected_team] = createSignal<string | null>(null);
export const [selected_game, set_selected_game] = createSignal<GameProps | null>(null);

export default function Editor() {
	const [tourn_name, set_tourn_name] = createSignal<string>("");
	const [tourn_path, set_tourn_path] = createSignal<string>("");

	const navigate = useNavigate()

	const keydown_handler = (e: KeyboardEvent) => {
		if (e.key === "Escape") {
			e.preventDefault();
			navigate("/")
		}
	};
	onMount(() => window.addEventListener("keydown", keydown_handler));
	onCleanup(() => window.removeEventListener("keydown", keydown_handler));

	// TODO make team list scrolling
	// TODO CONSIDER margin between lists and forms
	return (
		<div id="editor">
			<h2>Neues Turnier erstellen</h2>
			<div class="content">
				<form onsubmit={e => e.preventDefault()}>
					<label>Turniername</label><br/>
					<input
						value={tourn_name()}
						onchange={e => set_tourn_name(e.currentTarget.value)}
					/>
				</form>

				<form onsubmit={e => e.preventDefault()}>
					<label>Ort der Turnier-Datei</label><br/>
					<input
						value={tourn_path()}
						onchange={e => {
							let input = e.currentTarget.value
							if (!input.endsWith(".json")) input = input + ".json"
							set_tourn_path(input)
						}}
					/>
					<button type="button" onclick={async () => {
						const selected = await open({
							title: "Ordner für die Turnier-Datei auswählen",
							directory: true,
							canCreateDirectories: true
						})
						if (selected !== null)
							set_tourn_path(selected + "/" + generate_basename(tourn_name()))
					}}>Ordner auswählen</button>
				</form>

				<div class="team-division">
					<div class="team-list">
						<p>Teilnehmenden Teams</p>
						<ul role="listbox">{
							Object.values(teams).map(team => (
								<Team
									name={team.name}
									color={team.color}
									players={team.players}
								/>
							))
						}</ul>
						<Form
							name="team-name"
							placeholder="Teamnamen eintragen"
							callback={input => set_teams(team_id(input), {
								name: input,
								color: "#ff0000",
								players: []
							})}
						/>
					</div>

					<div class="player-division">
						<div class="role-list">
							<p>Spielerrollen</p>
							<ul role="listbox">{
								// TODO NOW
								Object.values(roles).map(role => (
									<Role name={role}/>
								))
							}</ul>
							<Form
								name="role-name"
								placeholder="Rollennamen eintragen"
								callback={input => set_roles(role_id(input), input)}
							/>
						</div>

						<div class="player-list">
							<p>Spieler des Teams</p>
							<ul role="listbox">{(() => {
								const sel = selected_team()
								if (sel === null) return <></>
								// TODO NOW
								return teams[sel].players.map(player => (
									<Player name={player.name} role={player.role}/>
								))
							})()
							}</ul>
							<Form
								name="player-list"
								placeholder="Vor- und Nachnamen eintragen"
								callback={input => set_teams(
									selected_team()!,
									"players",
									prev => [...prev, { name: input, role: 0 }]
								)}
							/>
						</div>
					</div>
				</div>
				<div class="game-list">
					<p>Turnierverlauf</p>
					<ul role="listbox">{
						games().map(game => (
							<Game left={game.left} right={game.right}/>
						))
					}</ul>
					<div class="buttons">
						<button onclick={() => set_games([
							...games(),
							{ left: 0, right: 0}
						])}>Add game</button>
						<button>Remove game</button>
					</div>
				</div>
			</div>
			<div class="navigation">
				<button onclick={() => navigate("/")}>Abbrechen</button>
				<button onclick={() => navigate("/")}>Speichern und Zurück</button>
				<button onclick={() => navigate("/input")}>Speichern und Starten</button>
			</div>
		</div>
	);
}
