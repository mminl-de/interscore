/* @refresh reload */
import { render } from "solid-js/web";
import { Router, Route } from "@solidjs/router";
import Launcher from "./launcher/Launcher";
import Editor from "./editor/Editor";

render(
	() => (
		<Router>
			<Route path="/" component={Launcher}/>
			<Route path="/editor" component={Editor}/>
		</Router>
	),
	document.getElementById("root") as HTMLElement
)
