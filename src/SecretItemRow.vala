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
    public Gtk.Revealer close_revealer { get; private set; }
    public Secret.Item secret_item { get; construct; }

    public SecretItemRow (Secret.Item secret_item) {
        Object (secret_item: secret_item);
    }

    construct {
        var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.BUTTON);
        close_button.margin_start = 6;
        close_button.valign = Gtk.Align.CENTER;
        close_button.get_style_context ().add_class ("close");

        close_revealer = new Gtk.Revealer ();
        close_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;
        close_revealer.add (close_button);

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
        grid.margin_start = 0;
        grid.attach (close_revealer, 0, 0, 1, 2);
        grid.attach (new Gtk.Image.from_icon_name ("payment-card", Gtk.IconSize.DND), 1, 0, 1, 2);
        grid.attach (title_label, 2, 0);
        grid.attach (description, 2, 1);
        grid.attach (button, 3, 0, 1, 2);

        var revealer = new Gtk.Revealer ();
        revealer.reveal_child = true;
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        revealer.add (grid);

        var eventbox = new Gtk.EventBox ();
        eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        eventbox.add (revealer);

        add (eventbox);

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

        close_button.clicked.connect (() => {
            revealer.reveal_child = false;
            GLib.Timeout.add (revealer.transition_duration, () => {
                destroy ();
                return false;
            });
        });

        eventbox.enter_notify_event.connect (() => {
            close_revealer.reveal_child = true;
            return Gdk.EVENT_STOP;
        });

        eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return Gdk.EVENT_PROPAGATE;
            }

            close_revealer.reveal_child = is_selected ();
            return Gdk.EVENT_STOP;
        });
    }
}
