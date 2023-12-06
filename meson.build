project('io.elementary.switchboard.wallet', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

css_gresource = gnome.compile_resources(
    'css-resource',
    join_paths('data', 'wallet.gresource.xml'),
    source_dir: 'data'
)

subdir('data')
subdir('src')
subdir('po')

