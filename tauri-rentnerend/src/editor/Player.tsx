import { roles } from "./EventEditor";

import "./Player.css";

export type PlayerProps = {
	name: string,
	role: number
};

export function Player(props: PlayerProps) {
	// TODO handle changing role
	// We're adding an empty option as a dummy option.
	return (
		<li class="editor-player">
			<div>{props.name}</div>
			<select value={props.role}>
				<option></option>
				{roles().map(role => (
					<option>{role}</option>
				))}
			</select>
		</li>
	);
}
