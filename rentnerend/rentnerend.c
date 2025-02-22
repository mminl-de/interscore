#include <gtk/gtk.h>

#define TEXT_SIZE 600

static GtkWidget *get_public_window(const GtkApplication *app) {
    GtkWidget *win = gtk_application_window_new(GTK_APPLICATION(app));
    gtk_window_set_title(GTK_WINDOW(win), "Interscore – public window");
    gtk_window_set_default_size(GTK_WINDOW(win), 800, 600);

	GtkWidget *grid = gtk_grid_new();
	GtkWidget *t1 = gtk_label_new("Gifhorn");
	GtkWidget *t2 = gtk_label_new("Ludwigsfelde");
	GtkWidget *s1 = gtk_label_new("2");
	GtkWidget *colon = gtk_label_new(":");
	GtkWidget *s2 = gtk_label_new("0");

	GtkWidget *time = gtk_label_new("6:59 left");

	PangoAttrList *attrlist = pango_attr_list_new();
	PangoAttribute *attr = pango_attr_size_new_absolute(TEXT_SIZE * PANGO_SCALE);
	pango_attr_list_insert(attrlist, attr);
	gtk_label_set_attributes(GTK_LABEL(s1), attrlist);
	pango_attr_list_unref(attrlist);

	gtk_grid_attach(GTK_GRID(grid), t1, 0, 0, 1, 1);
	gtk_grid_attach(GTK_GRID(grid), t2, 2, 0, 1, 1);
	gtk_grid_attach(GTK_GRID(grid), s1, 0, 1, 1, 1);
	gtk_grid_attach(GTK_GRID(grid), s2, 2, 1, 1, 1);
	gtk_grid_attach(GTK_GRID(grid), colon, 1, 1, 1, 1);
	gtk_grid_attach(GTK_GRID(grid), time, 0, 3, 3, 1);

	gtk_window_set_child(GTK_WINDOW(win), grid);

	return win;
}

static void on_activate(const GtkApplication *app) {
	const GtkWidget *pub_win = get_public_window(app);

	gtk_window_present(GTK_WINDOW(pub_win));
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("de.mminl.interscore",
                                              G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);

    const int stat = g_application_run(G_APPLICATION(app), argc, argv);

    g_object_unref(app);
    return stat;
}
