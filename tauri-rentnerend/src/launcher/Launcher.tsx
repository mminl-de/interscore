import { createSignal, onCleanup, onMount } from "solid-js";
import { useNavigate } from "@solidjs/router";
import { TournamentFile, TournamentFileProps } from "./TournamentFile";

import "../root.css";
import "./Launcher.css";

export default function Launcher() {
	const navigate = useNavigate()
	const [tourn_list] = createSignal<TournamentFileProps[]>([
		// TODO TEST
		{ name: "Gifhorn", path: "/home/me/downloads/gifhoen.json" }
	]);

	const keydown_handler = (e: KeyboardEvent) => {
		if (e.ctrlKey && e.key === "n") {
			e.preventDefault();
			navigate("/editor/meta");
		}
		if (e.ctrlKey && e.key === "o") {
			e.preventDefault();
			// TODO open tournament
		}
	};
	onMount(() => window.addEventListener("keydown", keydown_handler));
	onCleanup(() => window.removeEventListener("keydown", keydown_handler));

	return <div id="launcher">
		<h1>Interscore</h1>

		<div class="content">
			<div class="buttons">
				<button onclick={() => navigate("/editor/meta")}>Neues Turnier</button>
				<button onclick={() => {}}>Turnier laden</button>
				<button onclick={() => {}}>
					Aus cycleball.eu importieren
				</button>
			</div>
			<ul class="list">
				{tourn_list().map(item => <TournamentFile name={item.name} path={item.path}/>)}
			</ul>
		</div>
	</div>;
}
