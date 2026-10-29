# Fpx

Perform Flatpak operations.

This function facilitates common package management operations. It
automatically invokes sudo when necessary (may request a password).

Usage

`fpx <cmd> [opts ...] [args ...]`

Commands

lsi, lsia, lsir
: list installed packages. All by default, or just the applications (lsia),
or runtimes (lsir). The list includes both system and user installed
packages.

lsu, lsua, lsur
: list packages with available updates (AKA upgrades). All by default, or
just the applications (lsua), or runtimes (lsur). The list includes both
system and user installed packages.

in \[REMOTE\] REF
: install package REF from REMOTE. REF may be fully qualified package name,
a URI to a flatpakref file, or a keyword to start a search. This operates
on the system installation unless the -u/--user option is given.

rm \[REF ...\]
: uninstall package REF. Use --all to remove everything. This command
searches both the system and user installations for REF.

rmu
: uninstall unused runtimes and extensions, such as locale data. This
command operates on both the system and user installations.

cc
: clear out the contents of the default flatpak cache locations, namely
'/var/tmp/flatpak-cache-\*' and '~/.cache/flatpak/\*'.

rp
: prune objects that don't have an explicit reference to an app. This runs
with sudo to prune from the system installation in /var/lib/flatpak/repo/objects/.
Run it with -u/--user to prune from ~/.local/share/flatpak/repo/objects.

ud, update \[REMOTE\]
: update cached (appstream) info for REMOTE. If no REMOTE is given, all are
updated, for both --system and --user installations.

ug, upgrade \[REF ...\]
: upgrade specified REF. If no REF is given, everything is updated, as well
as appstream info for all remotes. Both --system and --user installed
packages are upgraded.

Options

-u, --user
: operate in user mode. This typically operates in ~/.local/share/flatpak/,
 rather than /var/lib/flatpak/. See manpage for details.
