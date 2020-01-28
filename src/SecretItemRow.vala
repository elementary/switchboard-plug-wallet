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

public class Wallet.SecretItemRow : Gtk.ListBoxRow {
    public Secret.Item secret_item { get; construct; }

    public SecretItemRow (Secret.Item secret_item) {
        Object (secret_item: secret_item);
    }

    construct {
        var title_label = new Gtk.Label (secret_item.get_label ());
        title_label.hexpand = true;
        title_label.xalign = 0;

        var description = new Gtk.Label (null);
        description.use_markup = true;
        description.xalign = 0;

        var button = new Gtk.Button.from_icon_name ("view-more-horizontal-symbolic", Gtk.IconSize.BUTTON);
        button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        var grid = new Gtk.Grid ();
        grid.column_spacing = 6;
        grid.margin = 6;
        grid.attach (new Gtk.Image.from_icon_name ("dialog-password", Gtk.IconSize.DND), 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (description, 1, 1);
        grid.attach (button, 2, 0, 1, 2);

        add (grid);

        var attributes = secret_item.get_attributes ();

        var username = attributes.get ("username");
        if (username != null) {
            description.label = "<small>%s</small>".printf (username);
        } else {
            description.label = "<small>%s</small>".printf (secret_item.get_schema_name ());
        }

        button.clicked.connect (() => {
            activate ();
        });
    }
}
