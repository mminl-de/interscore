import { roles } from "./Editor";

import "./Player.css";

type PlayerProps = {
	name: string,
	role: number
};

export function Player(props: PlayerProps) {
	// TODO handle changing role
	return (
		<li class="editor-player">
			<div>{props.name}</div>
			<select value={props.role}>{
				roles().map(role => (
					<option>{role}</option>
				))
			}</select>
		</li>
	);
}
