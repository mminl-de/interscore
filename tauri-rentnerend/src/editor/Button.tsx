import "./Button.css";

type ButtonProps = {
	text: string,
	onclick: () => void
};

export default function Button(props: ButtonProps) {
	return (
		<div class="editor-button" onclick={props.onclick}>
			{props.text}
		</div>
	);
}
