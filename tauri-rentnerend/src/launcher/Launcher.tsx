import { createSignal, onCleanup, onMount } from "solid-js";
import { useNavigate } from "@solidjs/router";
import { TournamentFile, TournamentFileProps } from "./TournamentFile";

import "../root.css";
import "./Launcher.css";

function open_tournament() {}

function import_tournament() {}

export default function Launcher() {
	const navigate = useNavigate()
	const [tourn_list, _] = createSignal<TournamentFileProps[]>([
		// TODO TEST
		{ name: "Gifhorn", path: "/home/me/downloads/gifhoen.json" }
	]);

	const keydown_handler = (e: KeyboardEvent) => {
		if (e.ctrlKey && e.key === "n") {
			e.preventDefault();
			navigate("/editor/event")
		}
		if (e.ctrlKey && e.key === "o") {
			e.preventDefault();
			// TODO open tournament
		}
	};
	onMount(() => window.addEventListener("keydown", keydown_handler));
	onCleanup(() => window.removeEventListener("keydown", keydown_handler));

	return (
		<div id="launcher">
			<h1>Interscore</h1>

			<div class="content">
				<div class="buttons">
					<button onclick={() => navigate("/editor/event")}>Neues Turnier</button>
					<button onclick={open_tournament}>Turnier laden</button>
					<button onclick={import_tournament}>
						Aus cycleball.eu importieren
					</button>
				</div>
				<ul class="list">
					{tourn_list().map(item => (<TournamentFile name={item.name} path={item.path}/>))}
				</ul>
			</div>
		</div>
	);
}
