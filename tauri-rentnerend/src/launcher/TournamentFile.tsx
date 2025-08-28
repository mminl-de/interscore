import "../root.css";
import "./TournamentFile.css";

export type TournamentFileProps = {
	name: string,
	path: string
};

export function TournamentFile(props: TournamentFileProps) {
	return <li class="launcher-tournament-file">
		<div class="name">{props.name}</div>
		<div class="path">{props.path}</div>
	</li>;
}
