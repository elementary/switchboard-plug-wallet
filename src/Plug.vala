/*
 * Copyright (c) 2018 elementary LLC.
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

public class Payments.Plug : Switchboard.Plug {
    private MainView main_view;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("personal/payments", null);
        Object (category: Category.PERSONAL,
            code_name: "personal-pantheon-payments",
            display_name: _("Payments"),
            description: _("Manage payment methods"),
            icon: "payment-card",
            supported_settings: settings);
}

    public override Gtk.Widget get_widget () {
        if (main_view == null) {
            main_view = new MainView ();
            main_view.quit_plug.connect (() => hidden ());
        }

        return main_view;
    }

    public override void shown () {

    }

    public override void hidden () {

    }

    public override void search_callback (string location) {

    }

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ((GLib.CompareDataFunc<string>)strcmp, (Gee.EqualDataFunc<string>)str_equal);
        search_results.set ("%s → %s".printf (display_name, _("Credit Card")), "");
        search_results.set ("%s → %s".printf (display_name, _("Debit Card")), "");
        search_results.set ("%s → %s".printf (display_name, _("Payments")), "");
        search_results.set ("%s → %s".printf (display_name, _("AppCenter")), "");
        search_results.set ("%s → %s".printf (display_name, _("Fund")), "");
        return search_results;
}
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Payments plug");
    var plug = new Payments.Plug ();
    return plug;
}

