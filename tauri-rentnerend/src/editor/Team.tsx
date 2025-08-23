import { PlayerProps } from "./Player";

import "./Team.css";

export type TeamProps = {
	name: string,
	color: string,
	players: PlayerProps[]
};

export function Team(props: TeamProps) {
	return (
		<li class="editor-team">
			<div>{props.name}</div>
			<input type="color" value={props.color}/>
		</li>
	);
}
