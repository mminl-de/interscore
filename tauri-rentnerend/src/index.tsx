/* @refresh reload */
import { render } from "solid-js/web";
import { Router, Route } from "@solidjs/router";
import Launcher from "./launcher/Launcher";
import Event from "./editor/Event";

render(
	() => (
		<Router>
			<Route path="/" component={Launcher}/>
			<Route path="/editor/event" component={Event}/>
		</Router>
	),
	document.getElementById("root") as HTMLElement
)
