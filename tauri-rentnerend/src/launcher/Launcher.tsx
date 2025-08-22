import { createSignal, onCleanup, onMount } from "solid-js";
import { useNavigate } from "@solidjs/router";
import Button from "./Button";
import { ListItem, ListItemProps } from "./ListItem";

import "../root.css";
import "./Launcher.css";

function open_tournament() {}

function import_tournament() {}

export default function Launcher() {
	const navigate = useNavigate()
	const [tourn_list, _] = createSignal<ListItemProps[]>([
		// TODO TEST
		{ name: "Gifhorn", path: "/home/me/downloads/gifhoen.json" }
	]);

	const keydown_handler = (e: KeyboardEvent) => {
		if (e.ctrlKey && e.key === "n") {
			e.preventDefault();
			navigate("/editor")
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
					<Button text="Neues Turnier" onclick={() => navigate("/editor")}/>
					<Button text="Turnier laden" onclick={open_tournament}/>
					<Button text="Aus cycleball.eu importieren" onclick={import_tournament}/>
				</div>
				<ul class="list">
					{tourn_list().map(item => (<ListItem name={item.name} path={item.path}/>))}
				</ul>
			</div>
		</div>
	);
}
