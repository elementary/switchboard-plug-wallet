project('io.elementary.switchboard.wallet', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

css_gresource = gnome.compile_resources(
    'css-resource',
    join_paths('data', 'wallet.gresource.xml'),
    source_dir: 'data'
)

subdir('data')
subdir('src')
subdir('po')

