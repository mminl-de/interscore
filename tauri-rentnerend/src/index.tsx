/* @refresh reload */
import { render } from "solid-js/web";
import { Router, Route } from "@solidjs/router";
import Launcher from "./launcher/Launcher";
import EventEditor from "./editor/EventEditor";

render(
	() => <Router>
		<Route path="/" component={Launcher}/>
		<Route path="/editor/event" component={EventEditor}/>
	</Router>,
	document.getElementById("root") as HTMLElement
)
