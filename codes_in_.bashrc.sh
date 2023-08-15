PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
eval "n=\$$#"
[[ $n = , ]] &&{ ((HIDIRF=1-HIDIRF));(($#>1)) &&set -- ${@:1:(($#-1))}
}
case $1 in
.) pushd -0;;
-) pushd ~-;;
1)	popd 2>/dev/null;;
0) for i in ${DIRSTACK[@]};{ pushd "$i" ;};;
0[1-9]*-) n=${1%-}; while popd +$n 2>/dev/null ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for((i=n-m;i>=0;--i)) ;{ popd +$m 2>/dev/null ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd +$((n-i++)) 2>/dev/null ||break;};;
00) dirs -c;DIRS=;return;;
[1-9]|[1-9][0-9])
 m=;[ -d "$1" ]&&{
  m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/, since no index $1 in directory list"
 }
 if 2>/dev/null pushd "${DIRSTACK[$1]}";then echo -ne $m>&2
 else [[ $m ]] &&{ pushd "$1";echo $n>&2;}
 fi;;
,) DIRS=;((HIDIRF)) || DIRS=$DIRSB
 return;;
$PWD) DIRS=;return;;
?*)
 if type -a "$1" 2>/dev/null;then
   F=1
   [[ -d $1 ]] &&{
    echo "'$1' is a directory in the working dir. but it's a name of an executable too"
    read -N1 -p 'Is it meant as executable or a directory name (which next time append '/' to it on CLI)? (d / ELSE KEY) ' o
    [[ $o = [dD] ]] && F=
   }
   ((F)) &&{
    x=$1;args=;DNO=;shift
    if [[ $1 = - ]];then args=$args\ $PWD;shift
    elif [[ $1 = . ]];then args=$args\ ${DIRSTACK[@]: -1};shift
    fi
    for m;{
     [[ $m = -- ]] && DNO=1
     if [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^1-9]*)([1-9][0-9]?)(.*) ]] ;then
      f=${BASH_REMATCH[1]}
      n=${BASH_REMATCH[2]}
      b=${BASH_REMATCH[3]}
      if [[ $b =~ ^//.|^/$ ]] ;then
       b=${b/\/\//\/};dirn=$f$n${b%/}
       args=$args\ $dirn
      else
        if ((n<=${#DIRSTACK[@]})) ;then
         dirn=$f${DIRSTACK[n]}
         if [[ $m = */ ]] ;then echo -n $x>&2;read -ei "$args $dirn" args
         else args=$args\ $dirn$b;fi
       else
         echo -n "In '$m', $n is out of dir. stack range"
         if [[ -d $m ]] ;then
          echo -e " while it's an existing directory\nIf it's really meant directory, append '/' on CLI: '$f$n/$b'"
          read -N1 -p "So proceed with '$n' as directory oy abort? (y / ELSE KEY)" o
          [[ $o = [yY] ]] ||return 1
          args=$args\ $m
         else return 1;fi
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
IFS=$'\n'
l=`dirs -l -p`
l=$'\n'${l//$'\n'/$'\n\n'}$'\n'
o=
while :
do set -- $l
	l=${l//$'\n'$1$'\n'}
 [[ $l ]] || break
 o="'$1' $o"
done
cd $1
dirs -c
unset IFS C d
eval set -- $o
for i ;{ pushd "$i" 2>/dev/null ||C=$C\ $1;}
 [[ $C ]]&&echo "Directory stack was cleaned up of just removed'${C// /,}'">&2
{
 read l
 while read l
 do [[ $l =~ ^([1-9]+)\ +(.+) ]]
  d="$d\e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m "
 done
}< <(dirs -v)
DIRSB=$(echo -e "${d:+$d\n\r}")
DIRS=;((HIDIRF)) || DIRS=$DIRSB
}>/dev/null
