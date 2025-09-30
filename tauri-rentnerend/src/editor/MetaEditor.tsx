import { useNavigate } from "@solidjs/router";

export default function MetaEditor() {
	const navigate = useNavigate();

	return <div id="meta-editor">
		<h2>Spieleinstellungen</h2>
		<div class="content">
			<p>Sportart</p>
			<select>
				<option>Radball</option>
			</select>
		</div>
		<div class="navigation">
			<button onclick={() => navigate("/")}>Abbrechen</button>
			<button onclick={() => navigate("/editor/event")}>Weiter</button>
		</div>
	</div>;
}
