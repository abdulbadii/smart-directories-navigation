PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
{ 
    eval "n=\$$#";
    [[ $n = , ]] && { 
        ((HIDIRF=1-HIDIRF));
        (($#>1)) && set -- ${@:1:(($#-1))}
    };
    case $1 in 
        .)
            pushd -0
        ;;
        -)
            pushd ~-
        ;;
        1)
            popd 2> /dev/null
        ;;
        0)
            for i in ${DIRSTACK[@]};
            do
                pushd "$i";
            done
        ;;
        0[1-9]*-)
            n=${1%-};
            while popd +$n 2> /dev/null; do
                :;
            done
        ;;
        0[1-9]*-[1-9]*)
            m=${1%-*};
            n=${1#*-};
            for ((i=n-m; i>=0; --i))
            do
                popd +$m 2> /dev/null;
            done
        ;;
        0[1-9]*)
            i=;
            for n in "$@";
            do
                [[ $n = 0[1-9]* ]] || break;
                popd +$((n-i++)) 2> /dev/null || break;
            done
        ;;
        00)
            dirs -c;
            DIRS=;
            return
        ;;
        [1-9] | [1-9][0-9])
            m=;
            [ -d "$1" ] && { 
                m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n";
                n="Into directory $1/, since no index $1 in directory list"
            };
            if pushd "${DIRSTACK[$1]}" 2> /dev/null; then
                echo -ne $m 1>&2;
            else
                [[ -n $m ]] && { 
                    pushd "$1";
                    echo $n 1>&2
                };
            fi
        ;;
        ,)
            if ((HIDIRF)); then
                echo NOW DIRECTORY STACK LIST IS HIDDEN 1>&2;
                DIRS=;
            else
                DIRS=$DIRSB;
            fi;
            return
        ;;
        $PWD)
            return
        ;;
        ?*)
            if type -a "$1" 2> /dev/null; then
                F=1;
                [[ -d $1 ]] && { 
                    echo "'$1' is a directory in the working dir. but it's a name of an executable too";
                    read -N1 -p 'Is it meant as executable or a directory name (must be appended with / on CLI)? (d / ELSE KEY) ' o;
                    [[ $o = [dD] ]] && { 
                        pushd $1;
                        F=
                    }
                };
                ((F)) && { 
                    x=$1;
                    shift;
                    args=;
                    DNO=;
                    [[ $1 = . ]] && { 
                        args= ${DIRSTACK[@]: -1};
                        shift
                    };
                    for m in "$@";
                    do
                        [[ $m = -- ]] && DNO=1;
                        if [[ $m =~ ^-(/.*)? ]]; then
                            b=${BASH_REMATCH[1]};
                            if [[ $m = */ ]]; then
                                echo -n $x 1>&2;
                                read -ei "$args ~-$b" args;
                            else
                                args=$args\ ~-$b;
                            fi;
                        else
                            if [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^1-9]*)([1-9][0-9]?)(.*) ]]; then
                                f=${BASH_REMATCH[1]};
                                n=${BASH_REMATCH[2]};
                                b=${BASH_REMATCH[3]};
                                if [[ $b =~ ^//.|^/$ ]]; then
                                    b=${b/\/\//\/};
                                    args=$args\ $f$n${b%/};
                                else
                                    if ((n<=${#DIRSTACK[@]})); then
                                        dirn=$f${DIRSTACK[n]}$b;
                                        if [[ $m = */ ]]; then
                                            echo -n $x 1>&2;
                                            read -ei "$args $dirn" args;
                                        else
                                            args=$args\ $dirn;
                                        fi;
                                    else
                                        echo -n "In '$m', $n is out of dir. stack range";
                                        [[ -d $m ]] && echo ", while it's a directory. Not proceeding it";
                                        echo -e "\nTo predetermine a number in argument isn't any of dir. stack, append '/' on CLI:\n'$f$n/$b'";
                                    fi;
                                fi;
                            else
                                args=$args\ $m;
                            fi;
                        fi;
                    done;
                    eval "$x $args"
                };
            else
                if (((i=$#)>1)); then
                    C=$PWD;
                    while ((i)); do
                        eval "n=\${$((i--))}";
                        if [[ $n = /* ]]; then
                            [[ -d $n ]] && pushd "$n";
                        else
                            [[ -d $C/$n ]] && pushd "$C/$n";
                        fi;
                    done;
                    pushd -0;
                    pushd ~-;
                else
                    pushd "$1";
                fi;
            fi
        ;;
        *)
            [[ $HOME = $PWD ]] || pushd ~
        ;;
    esac;
    IFS='
';
    l=`dirs -l -p`;
    l='
'${l//'
'/'

'}'
';
    o=;
    while :; do
        set -- $l;
        l=${l//'
'$1'
'};
        [[ -n $l ]] || break;
        o="'$1' $o";
    done;
    cd $1;
    dirs -c;
    unset IFS C d;
    eval set -- $o;
    for i in "$@";
    do
        pushd "$i" 2> /dev/null || C=$C\ $1;
    done;
    [[ -n $C ]] && echo "Directory stack was cleaned up of just removed'${C// /,}'" 1>&2;
    { read l;
      while read l; do
            [[ $l =~ ^([1-9]+)\ +(.+) ]];
            d="$d\e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m ";
        done
    } < <(dirs -v);
    DIRSB=$(echo -e "${d:+$d\n\r}");
    if ((HIDIRF)); then
        echo ..HIDING DIRECTORY STACK LIST 1>&2;DIRS=;
    else
        DIRS=$DIRSB;
    fi
} > /dev/null
