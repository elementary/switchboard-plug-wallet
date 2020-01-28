/*
 * Copyright 2018-2020 elementary, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Cassidy James Blaede <c@ssidyjam.es>
 */

public class Wallet.MainView : Granite.SimpleSettingsPage {
    public signal void quit_plug ();

    private Gtk.ListBox listbox;

    public MainView () {
        Object (
            icon_name: "payment-card",
            title: _("Wallet"),
            activatable: false
        );
    }

    construct {
        var placeholder = new Gtk.Label (_("Empty Wallet"));
        placeholder.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        placeholder.show ();

        listbox = new Gtk.ListBox ();
        listbox.expand = true;
        listbox.set_placeholder (placeholder);

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        var frame = new Gtk.Frame (null);
        frame.add (scrolled_window);

        content_area.add (frame);
        show_all ();

        init_default_collection.begin ();
    }

    private async void init_default_collection () {
        try {
            var default_collection = yield Secret.Collection.for_alias (null, Secret.COLLECTION_DEFAULT, Secret.CollectionFlags.LOAD_ITEMS, null);

            foreach (unowned Secret.Item secret_item in default_collection.get_items ()) {
                var label = new Gtk.Label (secret_item.get_label ());
                label.xalign = 0;

                var grid = new Gtk.Grid ();
                grid.column_spacing = 6;
                grid.margin = 6;
                grid.add (new Gtk.Image.from_icon_name ("dialog-password", Gtk.IconSize.DND));
                grid.add (label);

                listbox.add (grid);
            }

            listbox.show_all ();
        } catch (Error error) {
            critical (error.message);
        }
    }
}
