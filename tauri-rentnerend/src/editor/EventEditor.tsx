import { open } from "@tauri-apps/plugin-dialog";
import { createSignal, onCleanup, onMount } from "solid-js";
import { useNavigate } from "@solidjs/router";
import Form from "./Form";
import { Game, GameProps } from "./Game";
import { Player } from "./Player";
import { Team, TeamProps, id_of } from "./Team";

import "../root.css";
import "./EventEditor.css";

// Truncates and converts casing of `input` into snake_case to generate a
// possible basename for a tournament file path.
function generate_basename(input: string): string {
	// TODO make it handle input present in tourn_path
	if (input === "") return "tournament.json";
	if (input.length > 20) input = input.slice(0, 20);
	return "/" + input.toLowerCase().replace(/\s|\./g, "_") + ".json";
}

// TODO handle: deleting a team resets affected games
// TODO handle: deleting a role resets the roles of those players
// TODO CHECK there is a dummy role with index 0 in the role list

export const [roles, set_roles] = createSignal<string[]>([]);
export const [teams, set_teams] = createSignal<Record<string, TeamProps>>({});
export const [selected_team, set_selected_team] = createSignal<string | null>(null);

export default function Editor() {
	const [tourn_name, set_tourn_name] = createSignal<string>("");
	const [tourn_path, set_tourn_path] = createSignal<string>("");
	const [games] = createSignal<GameProps[]>([
		{ left: 0, right: 1}
	]);

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
	// TODO NOW the selected_team (type number) strategy aint it, chief
	//     we need a more reliable way to store selected list items
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
							set_tourn_path(selected + generate_basename(tourn_name()))
					}}>Ordner auswählen</button>
				</form>

				<div class="team-division">
					<div class="team-list">
						<p>Teilnehmenden Teams</p>
						<ul role="listbox">{
							Object.values(teams()).map(team => (
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
							callback={input => set_teams({
								...teams(),
								[id_of(input)]: {
									name: input,
									color: "#ff0000",
									players: []
								}
							})}
						/>
					</div>

					<div class="player-division">
						<div class="role-list">
							<p>Spielerrollen</p>
							<ul>{
								roles().map(role => (
									<div>{role}</div>
								))
							}</ul>
							<Form
								name="role-name"
								placeholder="Rollennamen eintragen"
								callback={input => set_roles([...roles(), input])}
							/>
						</div>

						<div class="player-list">
							<p>Spieler des Teams</p>
							<ul>{(() => {
								const sel = selected_team()
								if (sel === null) return <></>
								// TODO NOW
								return teams()[sel].players.map(player => (
									<Player name={player.name} role={player.role}/>
								))
							})()
							}</ul>
							<Form
								name="player-list"
								placeholder="Vor- und Nachnamen eintragen"
								callback={input => teams()[selected_team()!].players
									.push({ name: input, role: 0 })
								}
							/>
						</div>
					</div>
				</div>
				<div class="game-list">
					<p>Turnierverlauf</p>
					<ul>{
						games().map(game => (
							<Game left={game.left} right={game.right}/>
						))
					}</ul>
					<div class="buttons">
						<button>Add game</button>
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
