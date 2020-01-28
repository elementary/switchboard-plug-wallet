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

public class Wallet.SecretItemDialog : Granite.MessageDialog {
    public Secret.Item secret_item { get; construct; }

    public SecretItemDialog (Secret.Item secret_item) {
        Object (
            buttons: Gtk.ButtonsType.CLOSE,
            image_icon: new ThemedIcon ("dialog-password"),
            primary_text: secret_item.get_label (),
            secret_item: secret_item
        );
    }

    construct {
        secondary_text = _("Last modified %s").printf (
            Granite.DateTime.get_relative_datetime (
                new DateTime.from_unix_utc ((int64) secret_item.get_created ())
            )
        );

        var attributes = secret_item.get_attributes ();

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 12;

        var username = attributes.get ("username");
        if (username != null) {
            var username_label = new Gtk.Label (_("Username:"));

            var username_entry = new Gtk.Entry ();
            username_entry.sensitive = false;
            username_entry.text = username;

            grid.attach (username_label, 0, 0);
            grid.attach (username_entry, 1, 0);
        }

        grid.show_all ();

        custom_bin.add (grid);

        foreach (unowned string key in attributes.get_keys ()) {
            critical (key);
            critical (attributes.get (key));
        }
    }
}
