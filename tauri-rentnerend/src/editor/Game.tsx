import { selected_game, set_selected_game, teams } from "./EventEditor";

import "./Game.css";

export type GameProps = {
	left: number,
	right: number
};

export function Game(props: GameProps) {
	const options = () => Object.values(teams).map(team => (
		<option value={team.name}>{team.name}</option>
	));
	const is_selected = () => {
		const sel = selected_game();
		return sel !== null && sel.left == props.left && sel.right === props.right;
	};
	return (
		<li
			role="option"
			tabindex="0"
			aria-selected={is_selected()}
			class={is_selected() ? "selected" : ""}
			onclick={() => set_selected_game(props)}
			onkeydown={e => {
				switch (e.key) {
					case "Enter":
						set_selected_game(props);
						break;
					case "ArrowUp":
						e.preventDefault();
						const prev = e.currentTarget.previousSibling as HTMLElement;
						if (prev === null) break;
						const selects = prev.querySelectorAll("select");
						const left = parseInt(selects[0].value);
						const right = parseInt(selects[1].value);
						set_selected_game({ left: left, right: right });
						break;
					case "ArrowDown": {
						e.preventDefault();
						const next = e.currentTarget.nextSibling as HTMLElement;
						if (next === null) break;
						const selects = next.querySelectorAll("select");
						const left = parseInt(selects[0].value);
						const right = parseInt(selects[1].value);
						set_selected_game({ left: left, right: right });
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
		</li>
	);
}
