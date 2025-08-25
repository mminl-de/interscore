import { teams, selected_team, set_selected_team } from "./EventEditor";
import { PlayerProps } from "./Player";

import "./Team.css";

const TEAM_ID_PREFIX = "team-list-i-";

export type TeamProps = {
	name: string,
	color: string,
	players: PlayerProps[]
};

export function team_id(name: string): string {
	return TEAM_ID_PREFIX + name.replace(/\s/g, "")
}

export function Team(props: TeamProps) {
	const id = team_id(props.name)
	const is_selected = () => selected_team() === id;
	return (
		<li
			id={id}
			role="option"
			tabindex="0"
			aria-selected={is_selected()}
			class={is_selected() ? " selected" : ""}
			onclick={() => set_selected_team(id)}
			onkeydown={e => {
				switch (e.key) {
					case "Enter":
						set_selected_team(id);
						break;
					case "ArrowUp":
						e.preventDefault();
						focus_next_team(id, -1);
						break;
					case "ArrowDown":
						e.preventDefault();
						focus_next_team(id, 1);
						break;
				}
			}}
		>
			<div>{props.name}</div>
			<input type="color" value={props.color}/>
		</li>
	);
}

function focus_next_team(cur_id: string, direction: 1 | -1) {
	const ids = Object.keys(teams);
	console.log(ids) // TODO
	const idx = ids.indexOf(cur_id);
	if (idx === -1) return;
	const next_idx = (idx + direction + ids.length) % ids.length;
	const next_id = ids[next_idx];
	const next_el = document.getElementById(next_id);
	set_selected_team(next_id)
	next_el?.focus();
}
