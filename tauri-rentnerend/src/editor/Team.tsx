import "./Team.css";

export type TeamProps = {
	name: string,
	color: string
}

export function Team(props: TeamProps) {
	return (
		<li class="editor-team">
			<div>{props.name}</div>
			<div class="color" style={"background-color: " + props.color}>
				{props.color}
			</div>
		</li>
	);
}
