/*
 * Copyright 2020 elementary, Inc.
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
 */

public class Wallet.SecretItemDialog : Gtk.Dialog {
    public Secret.Item secret_item { get; construct; }

    private Gtk.Entry password_entry;

    public SecretItemDialog (Secret.Item secret_item) {
        Object (secret_item: secret_item);
    }

    construct {
        var image = new Gtk.Image.from_icon_name ("dialog-password", Gtk.IconSize.DIALOG);
        image.valign = Gtk.Align.START;

        var title_entry = new Gtk.Entry ();
        title_entry.hexpand = true;
        title_entry.text = secret_item.get_label ();

        var attributes = secret_item.get_attributes ();

        int64 unix_time;
        var server_time_modified = attributes.get ("server_time_modified");
        if (server_time_modified != null) {
            unix_time = server_time_modified.to_int64 ();
        } else {
            unix_time = (int64) secret_item.get_created ();
        }

        var secondary_label = new Gtk.Label (_("Last modified %s").printf (
            Granite.DateTime.get_relative_datetime (
                new DateTime.from_unix_utc (unix_time)
            )
        ));
        secondary_label.halign = Gtk.Align.START;

        var title_grid = new Gtk.Grid ();
        title_grid.row_spacing = 3;
        title_grid.margin_bottom = 12;
        title_grid.attach (title_entry, 0, 0);
        title_grid.attach (secondary_label, 0, 1);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 12;
        grid.margin = 10;
        grid.margin_top = 0;
        grid.attach (image, 0, 0);
        grid.attach (title_grid, 1, 0, 2);

        var username = attributes.get ("username");
        if (username != null) {
            var username_label = new Gtk.Label (_("Username:"));
            username_label.halign = Gtk.Align.END;

            var username_entry = new Gtk.Entry ();
            username_entry.sensitive = false;
            username_entry.text = username;

            grid.attach (username_label, 1, 1);
            grid.attach (username_entry, 2, 1);
        }

        var password_label = new Gtk.Label (_("Password:"));
        password_label.halign = Gtk.Align.END;

        password_entry = new Gtk.Entry ();
        password_entry.hexpand = true;
        password_entry.input_purpose = Gtk.InputPurpose.PASSWORD;
        password_entry.sensitive = false;
        password_entry.visibility = false;

        var password_visible_check = new Gtk.CheckButton.with_label (_("Show password"));
        password_visible_check.bind_property ("active", password_entry, "visibility");

        grid.attach (password_label, 1, 2);
        grid.attach (password_entry, 2, 2);
        grid.attach (password_visible_check, 2, 3);
        grid.show_all ();

        default_width = 400;
        deletable = false;
        get_content_area ().add (grid);

        get_action_area ().margin = 5;

        add_button (_("Close"), Gtk.ResponseType.CLOSE);

        init_secret.begin ();

        title_entry.changed.connect (() => {
            set_secret_label.begin (title_entry.text);
        });
    }

    private async void init_secret () {
        try {
            yield secret_item.load_secret (null);

            var secret_value = secret_item.get_secret ();

            password_entry.text = secret_value.get_text ();
        } catch (Error error) {
            critical (error.message);
        }
    }

    private async void set_secret_label (string label) {
        try {
            yield secret_item.set_label (label, null);
        } catch (Error error) {
            critical (error.message);
        }
    }
}
