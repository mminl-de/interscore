import "./root.css";
import "./StartListItem.css";

export type StartListItemData = {
	name: string,
	path: string
};

export function StartListItem(props: StartListItemData) {
	return (
		<li class="start-list-item">
			<div class="name">{props.name}</div>
			<div class="path">{props.path}</div>
		</li>
	);
}
