import { teams, selected_team, set_selected_team } from "./EventEditor";
import { PlayerProps } from "./Player";

import "./Team.css";

const TEAM_ID_PREFIX = "team-list-i-";

export type TeamProps = {
	name: string,
	color: string,
	players: PlayerProps[]
};

export function id_of(name: string): string {
	return TEAM_ID_PREFIX + name.replace(/\s/g, "")
}

export function Team(props: TeamProps) {
	const id = id_of(props.name)
	const is_selected = () => selected_team() === id;
	return (
		<li
			id={id}
			role="option"
			tabindex="0"
			aria-selected={is_selected()}
			class={"editor-team" + (is_selected() ? " selected" : "")}
			onclick={() => set_selected_team(id)}
			onKeyDown={e => {
				if (e.key === "Enter") {
					set_selected_team(id);
				} else if (e.key === "ArrowUp") {
					console.log("pressing up TODO")
					e.preventDefault();
					focus_next_team(id, -1);
				} else if (e.key === "ArrowDown") {
					e.preventDefault();
					focus_next_team(id, 1);
				}
			}}
		>
			<div>{props.name}</div>
			<input type="color" value={props.color}/>
		</li>
	);
}

function focus_next_team(cur_id: string, direction: 1 | -1) {
	const ids = Object.keys(teams());
	const idx = ids.indexOf(cur_id);
	if (idx === -1) return;
	const next_idx = (idx + direction + ids.length) % ids.length;
	const next_id = ids[next_idx];
	const next_el = document.getElementById(next_id);
	set_selected_team(next_id)
	next_el?.focus();
}
