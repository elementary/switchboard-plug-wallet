/*
* Copyright 2016-2020 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class Wallet.NewCardDialog : Gtk.Dialog {
    public Secret.Collection collection { get; construct; }

    private Gtk.Button pay_button;
    private Gtk.Entry card_expiration_entry;
    private Gtk.Entry card_cvc_entry;
    private Wallet.CardNumberEntry card_number_entry;

    private bool card_valid = false;
    private bool expiration_valid = false;
    private bool cvc_valid = false;

    public NewCardDialog (Secret.Collection collection) {
        Object (collection: collection);
    }

    construct {
        var image = new Gtk.Image.from_icon_name ("payment-card", Gtk.IconSize.DIALOG);
        image.valign = Gtk.Align.START;

        var primary_label = new Gtk.Label (_("Add a new card"));
        primary_label.get_style_context ().add_class (Granite.STYLE_CLASS_PRIMARY_LABEL);
        primary_label.xalign = 0;

        var secondary_label = new Gtk.Label (_("Card information is stored encrypted, on your device."));
        secondary_label.margin_bottom = 18;
        secondary_label.max_width_chars = 50;
        secondary_label.wrap = true;
        secondary_label.xalign = 0;

        card_number_entry = new Wallet.CardNumberEntry ();
        card_number_entry.activates_default = true;
        card_number_entry.hexpand = true;
        card_number_entry.bind_property ("has-focus", card_number_entry, "visibility");

        card_expiration_entry = new Gtk.Entry ();
        card_expiration_entry.activates_default = true;
        card_expiration_entry.hexpand = true;
        card_expiration_entry.max_length = 5;
        /// TRANSLATORS: Don't change the order, only transliterate
        card_expiration_entry.placeholder_text = _("MM / YY");
        card_expiration_entry.primary_icon_name = "office-calendar-symbolic";

        card_cvc_entry = new Gtk.Entry ();
        card_cvc_entry.activates_default = true;
        card_cvc_entry.hexpand = true;
        card_cvc_entry.input_purpose = Gtk.InputPurpose.DIGITS;
        card_cvc_entry.max_length = 4;
        card_cvc_entry.placeholder_text = _("CVC");
        card_cvc_entry.primary_icon_name = "channel-secure-symbolic";
        card_cvc_entry.bind_property ("has-focus", card_cvc_entry, "visibility");

        var card_grid_bottom = new Gtk.Grid ();
        card_grid_bottom.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        card_grid_bottom.add (card_expiration_entry);
        card_grid_bottom.add (card_cvc_entry);

        var card_grid = new Gtk.Grid ();
        card_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        card_grid.orientation = Gtk.Orientation.VERTICAL;
        card_grid.add (card_number_entry);
        card_grid.add (card_grid_bottom);

        var card_layout = new Gtk.Grid ();
        card_layout.get_style_context ().add_class ("login");
        card_layout.column_spacing = 12;
        card_layout.row_spacing = 6;
        card_layout.margin = 10;
        card_layout.margin_top = 0;
        card_layout.attach (image, 0, 0, 1, 2);
        card_layout.attach (primary_label, 1, 0);
        card_layout.attach (secondary_label, 1, 1);
        card_layout.attach (card_grid, 1, 2);
        card_layout.show_all ();

        get_content_area ().add (card_layout);

        get_action_area ().margin = 5;

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);

        pay_button = (Gtk.Button) add_button (_("Add Card"), Gtk.ResponseType.APPLY);
        pay_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        pay_button.has_default = true;
        pay_button.sensitive = false;

        deletable = false;
        resizable = false;

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.APPLY) {
                create_secret_item.begin ();
            }

            destroy ();
        });

        card_number_entry.changed.connect (() => {
            validate_card_number (card_number_entry.card_number);
            validate_form ();
        });

        card_expiration_entry.changed.connect (() => {
            card_expiration_entry.text = card_expiration_entry.text.replace (" ", "");
            validate_expiration (card_expiration_entry.text);
            validate_form ();
        });

        card_expiration_entry.focus_out_event.connect (() => {
            var expiration_text = card_expiration_entry.text;
            if (!("/" in expiration_text) && expiration_text.char_count () > 2) {
                int position = 2;
                card_expiration_entry.insert_text ("/", 1, ref position);
            }
        });

        card_cvc_entry.changed.connect (() => {
            card_cvc_entry.text = card_cvc_entry.text.replace (" ", "");
            validate_cvc (card_cvc_entry.text);
            validate_form ();
        });
    }

    private async void create_secret_item () {
        var schema = new Secret.Schema (
            "io.elementary.switchboard.wallet", Secret.SchemaFlags.NONE,
            "brand", Secret.SchemaAttributeType.STRING,
            "exp", Secret.SchemaAttributeType.STRING
        );

        var brand = card_number_entry.card_type.to_string ();

        var attributes = new GLib.HashTable<string, string> (GLib.str_hash, GLib.str_equal);
        attributes["brand"] = brand;
        attributes["exp"] = card_expiration_entry.text;

        var secret = "
          {
            \"card\": {
              \"number\": %s,
              \"cvc\" %s
            }
          }
        ".printf (
            card_number_entry.card_number,
            card_cvc_entry.text
        );

        var secret_value = new Secret.Value (secret, -1, "text/json");

        var last_four = card_number_entry.card_number.substring (
            card_number_entry.card_number.length - 4,
            4
        );

        var label = _("%s ending in %s").printf (brand, last_four);

        try {
            yield Secret.Item.create (
                collection,
                schema,
                attributes,
                label,
                secret_value,
                Secret.ItemCreateFlags.NONE,
                null
            );
        } catch (Error error) {
            critical (error.message);
        }
    }

    private void validate_card_number (string numbers) {
        var char_count = numbers.char_count ();

        if (char_count < 14) {
            card_valid = false;
            return;
        }

        int hash = int.parse (numbers[char_count - 1:char_count]);

        int j = 1;
        int sum = 0;
        for (int i = char_count - 1; i > 0; i--) {
            var number = int.parse (numbers[i - 1:i]);
            if (j++ % 2 == 1) {
                number = number * 2;
                if (number > 9) {
                    number = number - 9;
                }
            }

            sum += number;
        }

        card_valid = (10 - (sum % 10)) % 10 == hash;
    }

    private void validate_expiration (string expiration) {
        if (expiration.length < 4) {
            expiration_valid = false;
        } else {
            try {
                var regex = new Regex ("""^[0-9]{2}\/?[0-9]{2}$""");
                expiration_valid = regex.match (expiration);
            } catch (Error e) {
                critical (e.message);
                expiration_valid = false;
            }
        }
    }

    private void validate_cvc (string cvc) {
        try {
            var regex = new Regex ("""[0-9]{3,4}""");
            cvc_valid = regex.match (cvc);
        } catch (Error e) {
            critical (e.message);
            cvc_valid = false;
        }
    }

    private void validate_form () {
        pay_button.sensitive = card_valid && expiration_valid && cvc_valid;
    }
}
