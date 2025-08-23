type FormProps = {
	name: string,
	placeholder: string,
	callback: (_: string) => void
};

export default function Form(props: FormProps) {
	return (
		<form
			onsubmit={e => {
				e.preventDefault();
				const input = e.currentTarget.elements
					.namedItem(props.name) as HTMLInputElement;
				const value = input.value.trim();
				input.value = "";

				if (value === "") return;
				props.callback(value)
			}}
		>
			<input name={props.name} placeholder={props.placeholder}/>
		</form>
	);
}
