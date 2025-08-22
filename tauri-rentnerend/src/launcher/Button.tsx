import "./Button.css";

type ButtonProps = {
	text: string,
	callback: () => void
};

export default function Button(props: ButtonProps) {
	return (
		<div class="launcher-button" onclick={props.callback}>
			{props.text}
		</div>
	);
}
