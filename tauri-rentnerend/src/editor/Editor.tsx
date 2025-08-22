import { open } from "@tauri-apps/plugin-dialog";
import { createSignal, onCleanup, onMount } from "solid-js";
import { useNavigate } from "@solidjs/router";
import Button from "./Button";
import { Team, TeamProps } from "./Team";

import "../root.css";
import "./Editor.css";

// Truncates and converts casing of `input` into snake_case.
function generate_basename(input: string): string {
	// TODO make it handle input present in tourn_path
	if (input === "") return "tournament.json";
	if (input.length > 20) input = input.slice(0, 20);
	return "/" + input.toLowerCase().replace(/\s|\./g, "_") + ".json";
}

export default function Editor() {
	const [tourn_name, set_tourn_name] = createSignal<string>("");
	const [tourn_path, set_tourn_path] = createSignal<string>("");
	const [teams] = createSignal<TeamProps[]>([
		// TODO TEST
		{ name: "Gifhorn", color: "#562323" },
		{ name: "Ludwigsf", color: "#bedbed" }
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
							teams().map(team =>
								(<Team name={team.name} color={team.color}/>)
							)
						}</ul>
						<input placeholder="Teamnamen eintragen"/>
					</div>

					<div class="player-division">
						<div class="role-list">
							<p>Spielerrollen</p>
							<ul class="list">{
								teams().map(team =>
									(<Team name={team.name} color={team.color}/>)
								)
							}</ul>
							<input placeholder="Rollennamen eintragen"/>
						</div>

						<div class="player-list">
							<p>Spieler des Teams</p>
							<ul class="list">{
								teams().map(team => (
									<Team name={team.name} color={team.color}/>
								))
							}</ul>
						</div>
					</div>
				</div>
				<p>Turnierverlauf</p>
				<input type="color"/>
			</div>
			<div class="navigation">
				<Button text="Abbrechen" onclick={() => navigate("/")}/>
				<Button text="Speichern und Zurück" onclick={() => navigate("/")}/>
				<Button text="Speichern und Starten" onclick={() => navigate("/input")}/>
			</div>
		</div>
	);
}
