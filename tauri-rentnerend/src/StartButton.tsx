import "./StartButton.css";

type StartButtonProps = {
	id: string,
	text: string,
	callback: () => void
};

export default function StartButton(props: StartButtonProps) {
	return (
		<div class="start-button" id={props.id} onclick={props.callback}>
			{props.text}
		</div>
	);
}
