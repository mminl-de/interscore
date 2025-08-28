import { createSignal } from "solid-js";
import { createStore } from "solid-js/store";
import { teams } from "./Team";

import "./Game.css";

const GAME_ID_PREFIX = "game-list-i-";

type GameId = string;
type GameProps = {
	id: GameId,
	left: string,
	right: string
};

export const [games, set_games] = createStore<Record<GameId, GameProps>>({});
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
				case "Delete":
					set_games(props.id, undefined as any);
					set_selected_game(null);
					break;
			}
		}}
	>
		<select
			value={games[props.id]?.left ?? ""}
			oninput={e => set_games(props.id, "left", e.currentTarget.value)}
		>
			<option value=""></option>
			{options()}
		</select>
		<p>vs.</p>
		<select
			value={games[props.id]?.right ?? ""}
			oninput={e => set_games(props.id, "right", e.currentTarget.value)}
		>
			<option value=""></option>
			{options()}
		</select>
	</li>;
}
