import "./StartButton.css";

type StartButtonProps = {
	text: string,
	callback: () => void
};

export default function StartButton(props: StartButtonProps) {
	return (
		<div class="start-button" onclick={props.callback}>
			{props.text}
		</div>
	);
}
