import { createSignal } from "solid-js";
import { useNavigate } from "@solidjs/router";
import Button from "./Button";
import { ListItem, ListItemData } from "./ListItem";

import "../root.css";
import "./Launcher.css";

function open_tournament() {}

function import_tournament() {}

export default function Launcher() {
	const navigate = useNavigate()
	const [tourn_list, _] = createSignal<ListItemData[]>([
		// TODO TEST
		{ name: "Gifhorn", path: "/home/me/downloads/gifhoen.json" }
	]);

	return (
		<div id="launcher">
			<h1>Interscore</h1>

			<div class="content">
				<div class="buttons">
					<Button text="Neues Turnier" callback={() => navigate("/editor")}/>
					<Button text="Turnier laden" callback={open_tournament}/>
					<Button text="Aus cycleball.eu importieren" callback={import_tournament}/>
				</div>
				<ul class="list">
					{tourn_list().map(item => (<ListItem name={item.name} path={item.path}/>))}
				</ul>
			</div>
		</div>
	);
}
