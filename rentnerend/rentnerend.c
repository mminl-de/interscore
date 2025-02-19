#include <gtk/gtk.h>

// Structure to hold scoreboard data
typedef struct {
    GtkWidget *team1_entry;
    GtkWidget *team2_entry;
    GtkWidget *score1_spin;
    GtkWidget *score2_spin;
    GtkWidget *time_label;
    int time_remaining;
    gboolean running;
} ScoreboardData;

// Update display window
void update_display(GtkWidget *label, const gchar *text) {
    gtk_label_set_text(GTK_LABEL(label), text);
}

// Timer callback function
gboolean update_timer(gpointer user_data) {
    ScoreboardData *data = (ScoreboardData *)user_data;
    if (data->running && data->time_remaining > 0) {
        data->time_remaining--;
        gchar time_str[16];
        g_snprintf(time_str, sizeof(time_str), "Time: %d sec", data->time_remaining);
        update_display(data->time_label, time_str);
        return G_SOURCE_CONTINUE;
    }
    return G_SOURCE_REMOVE;
}

// Start/Pause button callback
void toggle_timer(GtkButton *button, gpointer user_data) {
    ScoreboardData *data = (ScoreboardData *)user_data;
    data->running = !data->running;
    if (data->running) {
        g_timeout_add_seconds(1, update_timer, data);
    }
}

// Function to create the input window
GtkWidget* create_input_window(ScoreboardData *data) {
    GtkWidget *window = gtk_window_new();
    gtk_window_set_title(GTK_WINDOW(window), "Scoreboard Input");
    gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);

    GtkWidget *grid = gtk_grid_new();
    gtk_window_set_child(GTK_WINDOW(window), grid);

    data->team1_entry = gtk_entry_new();
    data->team2_entry = gtk_entry_new();
    data->score1_spin = gtk_spin_button_new_with_range(0, 100, 1);
    data->score2_spin = gtk_spin_button_new_with_range(0, 100, 1);

    GtkWidget *start_button = gtk_button_new_with_label("Start/Pause Timer");
    g_signal_connect(start_button, "clicked", G_CALLBACK(toggle_timer), data);

    gtk_grid_attach(GTK_GRID(grid), gtk_label_new("Team 1:"), 0, 0, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), data->team1_entry, 1, 0, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), gtk_label_new("Score 1:"), 0, 1, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), data->score1_spin, 1, 1, 1, 1);

    gtk_grid_attach(GTK_GRID(grid), gtk_label_new("Team 2:"), 0, 2, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), data->team2_entry, 1, 2, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), gtk_label_new("Score 2:"), 0, 3, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), data->score2_spin, 1, 3, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), start_button, 0, 4, 2, 1);

    return window;
}

// Function to create the display window
GtkWidget* create_display_window(ScoreboardData *data) {
    GtkWidget *window = gtk_window_new();
    gtk_window_set_title(GTK_WINDOW(window), "Scoreboard Display");
    gtk_window_set_default_size(GTK_WINDOW(window), 300, 100);

    GtkWidget *vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    gtk_window_set_child(GTK_WINDOW(window), vbox);

    GtkWidget *team1_label = gtk_label_new("Team 1: ");
    GtkWidget *team2_label = gtk_label_new("Team 2: ");
    data->time_label = gtk_label_new("Time: 0 sec");

    gtk_box_append(GTK_BOX(vbox), team1_label);
    gtk_box_append(GTK_BOX(vbox), team2_label);
    gtk_box_append(GTK_BOX(vbox), data->time_label);

    return window;
}

int main(int argc, char *argv[]) {
    gtk_init();

    ScoreboardData data = {0};
    data.time_remaining = 60;

    GtkWidget *input_window = create_input_window(&data);
    GtkWidget *display_window = create_display_window(&data);

    gtk_window_present(GTK_WINDOW(input_window));
    gtk_window_present(GTK_WINDOW(display_window));

    g_main_loop_run(g_main_loop_new(NULL, FALSE));
    return 0;
}
