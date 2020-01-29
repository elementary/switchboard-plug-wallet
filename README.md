# Wallet

## Building and Installation

You'll need the following dependencies:

* libgranite-dev>=0.5
* libgtk-3-dev
* libjson-glib-dev
* libsecret-1-dev
* libsoup2.4-dev
* libswitchboard-2.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install

