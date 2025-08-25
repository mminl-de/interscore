import { roles, selected_role, set_selected_role } from "./EventEditor";

import "./Role.css";

const ROLE_ID_PREFIX = "role-list-i-";

export function role_id(name: string): string {
	return ROLE_ID_PREFIX + name.replace(/\s/g, "")
}

export function Role(props: { name: string }) {
	const id = role_id(props.name)
	const is_selected = () => selected_role() === id;
	return (
		<li
			id={id}
			role="option"
			tabindex="0"
			aria-selected={is_selected()}
			class={is_selected() ? "selected" : ""}
			onclick={() => set_selected_role(id)}
			onkeydown={e => {
				switch (e.key) {
					case "Enter":
						set_selected_role(id);
						break;
					case "ArrowUp":
						e.preventDefault();
						focus_next_role(id, -1);
						break;
					case "ArrowDown":
						e.preventDefault();
						focus_next_role(id, 1);
						break;
				}
			}}
		>
			{props.name}
		</li>
	);
}

function focus_next_role(cur_id: string, direction: 1 | -1) {
	const role_list = Object.keys(roles);
	console.log(role_list) // TODO
	const idx = role_list.indexOf(cur_id);
	if (idx === -1) return;
	const next_idx = (idx + direction + role_list.length) % role_list.length
	const next_id = role_list[next_idx];
	const next_el = document.getElementById(next_id);
	set_selected_role(next_id)
	next_el?.focus();
}
