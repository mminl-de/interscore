import { createSignal } from "solid-js";
import { roles } from "./Role";

import "./Player.css";

export type PlayerProps = {
	name: string,
	role: number
};

export const [selected_player, set_selected_player] = createSignal<string | null>(null);

export function Player(props: PlayerProps) {
	const is_selected = () => selected_player() === props.name;

	// We're adding an empty option as a dummy.
	return <li
		role="option"
		tabindex="0"
		aria-selected={is_selected()}
		// TODO REMOVE ALL in favor of selecting for aria-selected="true" in CSS
		onclick={() => set_selected_player(props.name)}
		onkeydown={e => {
			switch (e.key) {
				case "Enter":
					set_selected_player(props.name);
					break;
				case "ArrowUp":
					e.preventDefault();
					const prev = e.currentTarget.previousSibling as HTMLElement;
					if (prev === null) break;
					prev.focus();
					const name = prev.querySelector("div")!.innerText;
					set_selected_player(name);
					break;
				case "ArrowDown": {
					e.preventDefault();
					const next = e.currentTarget.nextSibling as HTMLElement;
					if (next === null) break;
					next.focus();
					const name = next.querySelector("div")!.innerText;
					set_selected_player(name);
					break;
				}
			}
		}}
	>
		<div>{props.name}</div>
		<select value={props.role}>
			<option></option>
			{Object.keys(roles).map(role => (
				<option>{role}</option>
			))}
		</select>
	</li>;
}
