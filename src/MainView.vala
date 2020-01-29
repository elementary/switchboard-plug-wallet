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
            icon_name: "io.elementary.switchboard.wallet",
            title: _("Wallet"),
            activatable: false
        );
    }

    construct {
        var placeholder = new Gtk.Label (_("Empty Wallet"));
        placeholder.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        placeholder.show ();

        listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = false;
        listbox.expand = true;
        listbox.set_placeholder (placeholder);
        listbox.set_sort_func ((Gtk.ListBoxSortFunc) sort_func);

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        var frame = new Gtk.Frame (null);
        frame.add (scrolled_window);

        content_area.add (frame);
        show_all ();

        init_default_collection.begin ();

        listbox.row_activated.connect ((row) => {
            var secret_item = ((SecretItemRow) row).secret_item;

            var dialog = new SecretItemDialog (secret_item);
            dialog.transient_for = (Gtk.Window) get_toplevel ();
            dialog.run ();
            dialog.destroy ();
        });

        listbox.selected_rows_changed.connect (() => {
            foreach (unowned Gtk.Widget row in listbox.get_children ()) {
                ((SecretItemRow) row).close_revealer.reveal_child = ((SecretItemRow) row).is_selected ();
            }
        });
    }

    private async void init_default_collection () {
        try {
            var default_collection = yield Secret.Collection.for_alias (null, Secret.COLLECTION_DEFAULT, Secret.CollectionFlags.LOAD_ITEMS, null);

            foreach (unowned Secret.Item secret_item in default_collection.get_items ()) {
                var secret_item_row = new SecretItemRow (secret_item);

                listbox.add (secret_item_row);
            }

            listbox.show_all ();
        } catch (Error error) {
            critical (error.message);
        }
    }

    [CCode (instance_pos = -1)]
    private int sort_func (SecretItemRow row1, SecretItemRow row2) {
        return row1.secret_item.get_label ().collate (row2.secret_item.get_label ());
    }
}
