import { createSignal } from "solid-js";
import { teams } from "./Team";

import "./Game.css";

const GAME_ID_PREFIX = "game-list-i";

type GameId = string;
type GameProps = {
	id: GameId,
	left: number,
	right: number
};

export const [games, set_games] = createSignal<GameProps[]>([]);
export const [selected_game, set_selected_game] = createSignal<GameId | null>(null);

export function game_id(): string {
	return GAME_ID_PREFIX + Date.now();
}

export function Game(props: GameProps) {
	const options = () => Object.values(teams).map(team =>
		<option value={team.name}>{team.name}</option>
	);
	const is_selected = () => selected_game() === props.id;

	return <li
		id={props.id}
		role="option"
		tabindex="0"
		aria-selected={is_selected()}
		onclick={() => set_selected_game(props.id)}
		onkeydown={e => {
			switch (e.key) {
				case "Enter":
					set_selected_game(props.id);
					break;
				case "ArrowUp":
					e.preventDefault();
					const prev = e.currentTarget.previousSibling as HTMLElement;
					if (prev === null) break;
					prev.focus();
					set_selected_game(prev.id);
					break;
				case "ArrowDown": {
					e.preventDefault();
					const next = e.currentTarget.nextSibling as HTMLElement;
					if (next === null) break;
					next.focus();
					set_selected_game(next.id);
					break;
				}
			}
		}}
	>
		<select value={props.left}>
			<option></option>
			{options()}
		</select>
		<p>vs.</p>
		<select value={props.right}>
			<option></option>
			{options()}
		</select>
	</li>;
}
