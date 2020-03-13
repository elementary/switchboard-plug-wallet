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
    private Gtk.Overlay overlay;
    private Gtk.ListBox listbox;
    private Secret.Collection collection;

    public MainView () {
        Object (
            icon_name: "io.elementary.switchboard.wallet",
            title: _("Wallet"),
            activatable: false
        );
    }

    construct {
        var placeholder = new Granite.Widgets.AlertView (
            _("Save payment methods for later"),
            _("Add payment methods to Wallet by clicking the icon in the toolbar below."),
            ""
        );
        placeholder.show_all ();

        listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = false;
        listbox.expand = true;
        listbox.selection_mode = Gtk.SelectionMode.MULTIPLE;
        listbox.set_placeholder (placeholder);
        listbox.set_sort_func ((Gtk.ListBoxSortFunc) sort_func);

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        var add_button = new Gtk.Button.with_label (_("Add Payment Method…"));
        add_button.always_show_image = true;
        add_button.image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        add_button.margin = 3;
        add_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var action_bar = new Gtk.ActionBar ();
        action_bar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
        action_bar.add (add_button);

        var grid = new Gtk.Grid ();
        grid.attach (scrolled_window, 0, 0);
        grid.attach (action_bar, 0, 1);

        var frame = new Gtk.Frame (null);
        frame.add (grid);

        overlay = new Gtk.Overlay ();
        overlay.add (frame);

        content_area.add (overlay);
        show_all ();

        init_collection.begin ();

        add_button.clicked.connect (() => {
            var new_card_dialog = new NewCardDialog (collection);
            new_card_dialog.transient_for = (Gtk.Window) get_toplevel ();
            new_card_dialog.run ();
        });

        listbox.selected_rows_changed.connect (() => {
            foreach (unowned Gtk.Widget row in listbox.get_children ()) {
                ((SecretItemRow) row).close_revealer.reveal_child = ((SecretItemRow) row).is_selected ();
            }
        });
    }

    private async void init_collection () {
        try {
            collection = yield Secret.Collection.for_alias (null, Secret.COLLECTION_DEFAULT, Secret.CollectionFlags.LOAD_ITEMS, null);
            update_rows ();

            collection.notify["items"].connect (() => {
                update_rows ();
            });

        } catch (Error error) {
            critical (error.message);
        }
    }

    private void update_rows () {
        foreach (unowned Gtk.Widget widget in listbox.get_children ()) {
            widget.destroy ();
        }

        foreach (unowned Secret.Item secret_item in collection.get_items ()) {
            if (secret_item.get_schema_name () != "io.elementary.switchboard.wallet") {
                continue;
            }

            var secret_item_row = new SecretItemRow (secret_item);
            secret_item_row.delete_request.connect ((secret_item) => {
                var toast = new Granite.Widgets.Toast (_("'%s' Removed").printf (secret_item.get_label ()));
                toast.set_default_action (_("Undo"));
                toast.show_all ();

                overlay.add_overlay (toast);
                toast.send_notification ();

                var timeout = GLib.Timeout.add (4000, () => {
                    delete_secret (secret_item_row, secret_item);
                    toast.destroy ();
                    return GLib.Source.REMOVE;
                });

                toast.closed.connect (() => {
                    delete_secret (secret_item_row, secret_item);
                    toast.destroy ();
                });

                toast.default_action.connect (() => {
                    Source.remove (timeout);
                    secret_item_row.revealer.reveal_child = true;
                });
            });

            listbox.add (secret_item_row);
        }

        listbox.show_all ();
    }

    private async void delete_secret (SecretItemRow row, Secret.Item secret_item) {
        try {
            yield secret_item.delete (null);
            row.destroy ();
        } catch (Error error) {
            critical (error.message);
        }
    }

    [CCode (instance_pos = -1)]
    private int sort_func (SecretItemRow row1, SecretItemRow row2) {
        return row1.secret_item.get_label ().collate (row2.secret_item.get_label ());
    }
}
