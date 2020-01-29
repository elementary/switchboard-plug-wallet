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
    private Gtk.Button pay_button;

    private bool card_valid = false;
    private bool expiration_valid = false;
    private bool cvc_valid = false;

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

        var card_number_entry = new Wallet.CardNumberEntry ();
        card_number_entry.activates_default = true;
        card_number_entry.hexpand = true;
        card_number_entry.bind_property ("has-focus", card_number_entry, "visibility");

        var card_expiration_entry = new Gtk.Entry ();
        card_expiration_entry.activates_default = true;
        card_expiration_entry.hexpand = true;
        card_expiration_entry.max_length = 5;
        /// TRANSLATORS: Don't change the order, only transliterate
        card_expiration_entry.placeholder_text = _("MM / YY");
        card_expiration_entry.primary_icon_name = "office-calendar-symbolic";

        var card_cvc_entry = new Gtk.Entry ();
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

        response.connect (on_response);

        card_number_entry.changed.connect (() => {
            validate (1, card_number_entry.card_number);
        });

        card_expiration_entry.changed.connect (() => {
            card_expiration_entry.text = card_expiration_entry.text.replace (" ", "");
            validate (2, card_expiration_entry.text);
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
            validate (3, card_cvc_entry.text);
        });
    }

    private void validate (int entry, string new_text) {
        try {
            switch (entry) {
                case 1:
                    card_valid = is_card_valid (new_text);
                    break;
                case 2:
                    if (new_text.length < 4) {
                        expiration_valid = false;
                    } else {
                        var regex = new Regex ("""^[0-9]{2}\/?[0-9]{2}$""");
                        expiration_valid = regex.match (new_text);
                    }
                    break;
                case 3:
                    var regex = new Regex ("""[0-9]{3,4}""");
                    cvc_valid = regex.match (new_text);
                    break;
            }
        } catch (Error e) {
            warning (e.message);
        }

        if (card_valid && expiration_valid && cvc_valid) {
            pay_button.sensitive = true;
        } else {
            pay_button.sensitive = false;
        }
    }

    private bool is_card_valid (string numbers) {
        var char_count = numbers.char_count ();

        if (char_count < 14) return false;

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

        return (10 - (sum % 10)) % 10 == hash;
    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case Gtk.ResponseType.APPLY:

                break;
            case Gtk.ResponseType.CLOSE:

                destroy ();
                break;
        }
    }
}
