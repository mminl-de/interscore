import "../root.css";
import "./ListItem.css";

export type ListItemProps = {
	name: string,
	path: string
};

export function ListItem(props: ListItemProps) {
	return (
		<li class="start-list-item">
			<div class="name">{props.name}</div>
			<div class="path">{props.path}</div>
		</li>
	);
}
