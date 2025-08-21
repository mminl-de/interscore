import "./StartButton.css";

type StartButtonProps = {
	id: string,
	text: string
};

export default function StartButton(props: StartButtonProps) {
	return (
		<div class="start-button" id={props.id}>
			{props.text}
		</div>
	);
}
