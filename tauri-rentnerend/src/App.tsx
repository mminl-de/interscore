import { createSignal } from "solid-js";
import StartButton from "./StartButton";
import { StartListItem, StartListItemData } from "./StartListItem";

import "./root.css";
import "./App.css";

export default function App() {
	const [jsonList, setJsonList] = createSignal<StartListItemData[]>([
		{ name: "Ludwigsfelde", path: "/home/me/downloads/ludwigsf.json" }
	]);

	return (
		<main id="root">
			<h1>Interscore</h1>

			<div class="content">
				<div class="buttons">
					<StartButton id="b-new-tournament" text="Neues Turnier"/>
					<StartButton id="b-open-tournament" text="Turnier laden"/>
					<StartButton id="b-import-tournament" text="Aus cycleball.eu importieren"/>
				</div>
				<ul class="list">
					{jsonList().map(item => (<StartListItem name={item.name} path={item.path}/>))}
				</ul>
			</div>
		</main>
	);
}
