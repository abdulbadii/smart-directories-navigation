PS1=$(echo -e "${d:+$d\n\r}\e[41;1;37m%~\e[40;1;33m\n%%\e[m ")
g(){
[[ ${@:-1} = , ]] &&{ ((HIDIRF=1-HIDIRF));((#>1)) &&set -- ${@:1:-1}}
IFS=$'\n'
d=(`dirs -pl`)
DIRST=(${d:1})
case $1 in
.) pushd -0;;
-) pushd ~-;;
1) popd 2>/dev/null;;
0) for i in $DIRST ;{ pushd "$i"};;
0[1-9]*-) n=${1%-}; while popd +$n 2>/dev/null ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for ((i=n-m;i>=0;--i)) ;{ popd +$m 2>/dev/null ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd +$((n-i++)) 2>/dev/null ||break};;
00) dirs -c;PS1=$(echo -e "\e[41;1;37m%~\e[40;1;33m\n%%\e[m ");return;;
[1-9]|[1-9][0-9])
 m=;[ -d "$1" ]&&{
  m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/, since no index $1 in directory list"
 }
 if 2>/dev/null pushd "${DIRST[$1]}";then echo -ne $m>&2
 else [[ $m ]] &&{ pushd "$1";echo $n>&2}
 fi;;
,) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN>&2;DIRS=
  else DIRS=$DIRSB ;fi
  PS1=$(echo -e "$DIRS\e[41;1;37m%~\e[40;1;33m\n%%\e[m ");return;;
$PWD)return;;
?*)
 if type -a "$1" 2>/dev/null;then F=1
   [[ -d $1 ]] &&{
    echo "'$1' is a directory in the working dir. but it's a name of an executable too"
    read -N1 -p 'Is it an executable or directory name (which must be appended with / on CLI) ? (x / ELSE KEY) ' o
    [[ $o = [xX] ]] ||{ pushd  $1;F= }
   }
   ((F)) &&{
    x=$1;shift;args=;DNO=
    [[ $1 = . ]] &&{ args= ${DIRS: -1};shift}
    for m;{
     [[ $m = -- ]] && DNO=1
     if [[ $m =~ "^-(/.*)?" ]];then b=${match[1]}
      if [[ $m = */ ]] ;then echo -n $x>&2
      args="$args ~-$b"
      vared args
      else args=$args\ ~-$b;fi
     elif [[ $m != -* ]] || ((DNO)) && [[ $m =~ "^([^1-9]*)([1-9][0-9]?)(.*)" ]] ;then
      f=${match[1]}
      n=${match[2]}
      b=${match[3]}
      if [[ $b =~ "^//.|^/$" ]] ;then
       b=${b/\/\//\/}
       args=$args\ $f$n${b%/}
      else
        if ((n<=$#DIRST)) ;then
         dirn=$f$DIRSTACK[n]$b
         if [[ $m = */ ]] ;then echo -n $x>&2
         args="$args $dirn"
         vared args
         else args=$args\ $dirn;fi
       else
         echo -n "In '$m', $n is out of dir. stack range"
         [[ -d $m ]] && echo ", while it's a directory. Will not proceed"
         echo -e "\nTo predetermine a number in argument isn't any of dir. stack, append '/' on CLI:\n'$f$n/$b'"
        fi
       fi
     else args=$args\ $m;fi
     }
     eval "$x $args"
    }
else
  if (((i=$#)>1)) ;then C=$PWD
   while ((i)) ;do
    eval "n=\${$((i--))}"
    if [[ $n = /* ]] ;then [[ -d $n ]] &&pushd "$n" 
    else [[ -d $C/$n ]] &&pushd "$C/$n";fi
   done
   pushd -0;pushd ~-
  else pushd "$1";fi
fi;;
*) [[ $HOME = $PWD ]] ||pushd ~
esac
l=`dirs -pl`
l=$'\n'${l//$'\n'/$'\n\n'}$'\n'
o=
while :
do set -- $=l
	l=${l//$'\n'$1$'\n'}
 [[ $l ]] || break
 o="'$1' $o"
done
cd $1
dirs -c
eval set -- $=o
W=;for d;{ pushd "$d" 2>/dev/null ||C=$C\ $1;}
 [[ $C ]]&&echo "Directory stack was cleaned up of just removed'${C// /,}'">&2
{
 read l
 d=;while read l
 do [[ $l =~ "^([1-9]+)\h+(.+)" ]]
  d="$d\e[41;1;37m${match[1]}\e[40;1;32m${match[2]}\e[m "
 done
}< <(dirs -v)
DIRSB=$(echo -e "${d:+$d\n\r}")
 if ((HIDIRF)) ;then echo ..HIDING DIRECTORY STACK LIST>&2;DIRS=
 else DIRS=$DIRSB ;fi
 PS1=$(echo -e "$DIRS\e[41;1;37m%~\e[40;1;33m\n%%\e[m ")
}>/dev/null
