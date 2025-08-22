use tauri::{
	Builder,
	generate_context,
	generate_handler
};

#[cfg_attr(mobile, mobile_entry_point)]
pub fn run() {
	Builder::default()
		.plugin(tauri_plugin_opener::init())
		.plugin(tauri_plugin_dialog::init())
		//.invoke_handler(generate_handler![/*function_name*/])
		.run(generate_context!())
		.expect("error while running tauri application");
}
