plug_files = files(
    'Dialogs/NewCardDialog.vala',
    'Widgets/CardNumberEntry.vala',
    'Widgets/SecretItemRow.vala',
    'MainView.vala',
    'Plug.vala'
)

switchboard_dep = dependency('switchboard-2.0')
switchboard_plugsdir = switchboard_dep.get_pkgconfig_variable('plugsdir', define_variable: ['libdir', libdir])

shared_module(
    meson.project_name(),
    plug_files,
    config_file,
    css_gresource,
    dependencies: [
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libsecret-1'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'personal')
)

