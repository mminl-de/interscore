import "../root.css";
import "./ListItem.css";

export type ListItemData = {
	name: string,
	path: string
};

export function ListItem(props: ListItemData) {
	return (
		<li class="start-list-item">
			<div class="name">{props.name}</div>
			<div class="path">{props.path}</div>
		</li>
	);
}
