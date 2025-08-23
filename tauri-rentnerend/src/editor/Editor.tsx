import { open } from "@tauri-apps/plugin-dialog";
import { createSignal, onCleanup, onMount } from "solid-js";
import { useNavigate } from "@solidjs/router";
import Button from "./Button";
import { Player } from "./Player";
import { Team, TeamProps } from "./Team";

import "../root.css";
import "./Editor.css";

// Truncates and converts casing of `input` into snake_case to generate a
// possible basename for a tournament file path.
function generate_basename(input: string): string {
	// TODO make it handle input present in tourn_path
	if (input === "") return "tournament.json";
	if (input.length > 20) input = input.slice(0, 20);
	return "/" + input.toLowerCase().replace(/\s|\./g, "_") + ".json";
}

// TODO handle: deleting a role resets the roles of those players
export const [roles] = createSignal<string[]>([
	// TODO TEST
	"Keeper",
	"Fan"
]);

export default function Editor() {
	const [tourn_name, set_tourn_name] = createSignal<string>("");
	const [tourn_path, set_tourn_path] = createSignal<string>("");
	const [teams] = createSignal<TeamProps[]>([
		// TODO TEST
		{
			name: "Gifhorn",
			color: "#562323",
			players: [
				{ name: "Linux Kramer", role: 1 },
				{ name: "Felix Kramer", role: 0 }
			]
		},
		{ name: "Ludwigsf", color: "#bedbed", players: [] }
	]);
	const [team_i] = createSignal<number | null>(0); // TODO FINAL should be null by default
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
	return (
		<div id="editor">
			<h2>Neues Turnier erstellen</h2>
			<div class="content">
				<form onsubmit={(e: SubmitEvent) => e.preventDefault()}>
					<label>Turniername</label><br/>
					<input
						value={tourn_name()}
						onchange={(e) => set_tourn_name(e.currentTarget.value)}
					/>
				</form>

				<form onsubmit={(e: SubmitEvent) => e.preventDefault()}>
					<label>Ort der Turnier-Datei</label><br/>
					<input
						value={tourn_path()}
						onchange={(e) => {
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
						<ul class="list">{
							teams().map(team => (
								<Team
									name={team.name}
									color={team.color}
									players={team.players}
								/>
							))
						}</ul>
						<input placeholder="Teamnamen eintragen"/>
					</div>

					<div class="player-division">
						<div class="role-list">
							<p>Spielerrollen</p>
							<ul class="list">{
								roles().map(role => (
									<div>{role}</div>
								))
							}</ul>
							<input placeholder="Rollennamen eintragen"/>
						</div>

						<div class="player-list">
							<p>Spieler des Teams</p>
							<ul class="list">{(() => {
								const i = team_i()
								if (i === null) return <></>
								// TODO NOW
								return teams()[i].players.map(player => (
									<Player name={player.name} role={player.role}/>
								))
							})()
							}</ul>
							<input placeholder="Vor- und Nachnamen eintragen"/>
						</div>
					</div>
				</div>
				<p>Turnierverlauf</p>
			</div>
			<div class="navigation">
				<Button text="Abbrechen" onclick={() => navigate("/")}/>
				<Button text="Speichern und Zurück" onclick={() => navigate("/")}/>
				<Button text="Speichern und Starten" onclick={() => navigate("/input")}/>
			</div>
		</div>
	);
}
