import { teams } from "./EventEditor";

import "./Game.css";

export type GameProps = {
	left: number,
	right: number
};

export function Game(props: GameProps) {
	const options = () => Object.values(teams()).map(team => (
		<option value={team.name}>{team.name}</option>
	));

	return (
		<div class="editor-game">
			<select value={props.left}>{options()}</select>
			<p>vs.</p>
			<select value={props.right}>{options()}</select>
		</div>
	);
}
