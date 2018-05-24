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

public class Payments.MainView : Granite.SimpleSettingsPage {
    public signal void quit_plug ();

    public MainView () {
        Object (
            icon_name: "payment-method-card",
            title: _("Payment Method"),
            activatable: true,
            description: _("Used to buy apps in AppCenter. You are always prompted before a payment.")
        );
    }

    construct {
        var empty_alert = new Granite.Widgets.AlertView (
            _("No Payment Methods"),
            _("Add a payment method."),
            "dialog-information"
        );
        empty_alert.show_all ();

        margin = 12;
        margin_bottom = 0;

        show_all ();
    }
}

