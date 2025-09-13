/* @refresh reload */
import { render } from "solid-js/web";
import { Router, Route } from "@solidjs/router";
import Launcher from "./launcher/Launcher";
import EventEditor from "./editor/EventEditor";
import MetaEditor from "./editor/MetaEditor";

render(
	() => <Router>
		<Route path="/" component={Launcher}/>
		<Route path="/editor/meta" component={MetaEditor}/>
		<Route path="/editor/event" component={EventEditor}/>
	</Router>,
	document.getElementById("root") as HTMLElement
)
