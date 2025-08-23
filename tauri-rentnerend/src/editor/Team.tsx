import { PlayerProps } from "./Player";

import "./Team.css";

export type TeamProps = {
	name: string,
	color: string,
	players: PlayerProps[],
	selected: boolean,
	onclick: () => void
};

export function Team(props: TeamProps) {
	return (
		<li class={"editor-team" + (props.selected ? " selected" : "")}>
			<div>{props.name}</div>
			<input type="color" value={props.color}/>
		</li>
	);
}
