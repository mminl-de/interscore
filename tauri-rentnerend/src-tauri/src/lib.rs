use tauri::{
	command,
	Builder,
	Manager,
	WebviewUrl,
	WebviewWindow,
	WebviewWindowBuilder,
	generate_context,
	generate_handler
};

#[command]
async fn open_editor(parent: WebviewWindow) {
	WebviewWindowBuilder::new(
		parent.app_handle(),
		"editor",
		WebviewUrl::App("editor.html".into())
	)
		.title("Create new tournament")
		.always_on_top(true)
		.parent(&parent)
		.unwrap()
		.build()
		.unwrap();
}

#[cfg_attr(mobile, mobile_entry_point)]
pub fn run() {
    Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(generate_handler![open_editor])
        .run(generate_context!())
        .expect("error while running tauri application");
}
