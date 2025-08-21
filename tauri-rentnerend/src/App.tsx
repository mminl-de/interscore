import { invoke } from "@tauri-apps/api/core";
import { createSignal } from "solid-js";
import StartButton from "./StartButton";
import { StartListItem, StartListItemData } from "./StartListItem";

import "./root.css";
import "./App.css";

function new_tournament() { invoke("open_editor") }

function open_tournament() {}

function import_tournament() {}

export default function App() {
	const [jsonList, _] = createSignal<StartListItemData[]>([
		{ name: "Ludwigsfelde", path: "/home/me/downloads/ludwigsf.json" }
	]);

	return (
		<main id="root">
			<h1>Interscore</h1>

			<div class="content">
				<div class="buttons">
					<StartButton id="b-new-tournament" text="Neues Turnier" callback={new_tournament}/>
					<StartButton id="b-open-tournament" text="Turnier laden" callback={open_tournament}/>
					<StartButton id="b-import-tournament" text="Aus cycleball.eu importieren" callback={import_tournament}/>
				</div>
				<ul class="list">
					{jsonList().map(item => (<StartListItem name={item.name} path={item.path}/>))}
				</ul>
			</div>
		</main>
	);
}
