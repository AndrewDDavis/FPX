## dependencies
#import_func ...
#    || return

: """Perform Flatpak operations

    This function facilitates common package management operations. It
    automatically invokes sudo when necessary (may request a password).

    Usage

      fpx <cmd> [opts ...] [args ...]

    Commands

      lsi, lsia, lsir
      : list installed packages. All by default, or just the applications (lsia),
        or runtimes (lsir). The list includes both system and user installed
        packages.

      lsu, lsua, lsur
      : list packages with available updates (AKA upgrades). All by default, or
        just the applications (lsua), or runtimes (lsur). The list includes both
        system and user installed packages.

      in [REMOTE] REF
      : install package REF from REMOTE. REF may be fully qualified package name,
        a URI to a flatpakref file, or a keyword to start a search. This operates
        on the system installation unless the -u/--user option is given.

      rm [REF ...]
      : uninstall package REF. Use --all to remove everything. This command
        searches both the system and user installations for REF.

      rmu
      : uninstall unused runtimes and extensions, such as locale data. This
        command operates on both the system and user installations.

      cc
      : clear out the contents of the default flatpak cache locations, namely
        '/var/tmp/flatpak-cache-*' and '~/.cache/flatpak/*'.

      rp
      : prune objects that don't have an explicit reference to an app. This runs
        with sudo to prune from the system installation in /var/lib/flatpak/repo/objects/.
        Run it with -u/--user to prune from ~/.local/share/flatpak/repo/objects.

      ud, update [REMOTE]
      : update cached (appstream) info for REMOTE. If no REMOTE is given, all are
        updated, for both --system and --user installations.

      ug, upgrade [REF ...]
      : upgrade specified REF. If no REF is given, everything is updated, as well
        as appstream info for all remotes. Both --system and --user installed
        packages are upgraded.

    Options

       -u, --user
       : operate in user mode. This typically operates in ~/.local/share/flatpak/,
         rather than /var/lib/flatpak/. See manpage for details.
"""

fpx() (

    [[ $# -eq 0  || $1 == @(-h|--help) ]] \
        && { docsh -DT; return; }

    # return on error
    trap '
        #trap-err $?  # <- does not work with err_msg in Oct 2026
        return
    ' ERR

    trap '
        unset -f _args _run_priv \
            _fpx_lsi _fpx_lsu \
            _fpx_in _fpx_rm \
            _fpx_cc _fpx_rp \
            _fpx_ud _fpx_ug
        trap - ERR RETURN
    ' RETURN

    # check for flatpak
    if ! [[ -n $( command -v flatpak ) ]]
    then
        err_msg 9 "flatpak command not found"
    fi

    _args() {

        # examine args, set variables and flags

        # main command should be first non-option arg
        local -i i=1
        while [[ ${!i} == -* ]]
        do
            (( ++i ))
        done
        cmd=${!i}
        set -- "${@:1:i-1}" "${@:i+1}"

        # check for --user
        local o
        for o in "$@"
        do
            if [[ $o == -u || $o == --user ]]
            then
                _u=1
                break
            fi
        done

        _argarr=( "$@" )
    }

    _run_priv() {

        # Prepend sudo when not root
        # - also echo the command line using set -x

        if (( $( id -u ) == 0 )) || [[ -v _u ]]
        then
            (
                set -x
                "$@"
            )
        else
            (
                set -x
                sudo "$@"
            )
        fi
    }

    _fpx_lsi() {
        # list installed packages
        case $cmd in
            ( lsia ) set -- --app "$@" ;;
            ( lsir ) set -- --runtime "$@" ;;
        esac
        (
            set -x
            flatpak list "$@"
        )
    }

    _fpx_lsu() {
        # list packages with available updates (AKA upgrades)
        case $cmd in
            ( lsua ) set -- --app "$@" ;;
            ( lsur ) set -- --runtime "$@" ;;
        esac
        (
            set -x
            flatpak remote-ls --updates "$@"
        )
    }

    _fpx_in() {

        # install package
        run_priv flatpak install "$@"
    }

    _fpx_rm() {
        # uninstall packages
        case $cmd in
            ( rmu ) set -- --unused "$@" ;;
        esac

        _run_priv flatpak uninstall "$@"
    }

    _fpx_cc() {

        # clear caches
        [[ -v _u ]] \
            || run_priv /bin/rm -rfv /var/tmp/flatpak-cache-*
        /bin/rm -rfv ~/.cache/flatpak/*
    }

    _fpx_rp() {

        # prune objects not in use by any app
        _run_priv flatpak repair
    }

    _fpx_ud() {
        # update cached info
        _run_priv flatpak update --appstream "$@"

        ## show a list of packages with pending upgrades, similar to apt
        ## - use sed to boldify the package name
        #_lsupgr -s
    }

    _fpx_ug() {
        # upgrade packages
        _run_priv flatpak update "$@"
    }

    # get cmd and examine args
    local _argarr cmd _u
    _args "$@"
    set -- "${_argarr[@]}"

    case $cmd in
        ( lsi | lsia | lsir )
            _fpx_lsi "$@" ;;
        ( lsu | lsua | lsur )
            _fpx_lsu "$@" ;;
        ( in )
            _fpx_in "$@" ;;
        ( rm | rmu )
            _fpx_rm "$@" ;;
        ( cc )
            _fpx_cc "$@" ;;
        ( rp )
            _fpx_rp "$@" ;;
        ( ud | update )
            _fpx_ud "$@" ;;
        ( ug | upgrade )
            _fpx_ug "$@" ;;
        ( * )
            err_msg 2 "Unknown command: '$cmd'" ;;
    esac
)
