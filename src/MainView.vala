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

        var listbox = new Gtk.ListBox ();
        listbox.expand = true;
        listbox.set_placeholder (placeholder);

        var frame = new Gtk.Frame (null);
        frame.add (listbox);

        content_area.add (frame);
        show_all ();
    }
}
