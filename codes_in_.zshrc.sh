PS1="$d%F{015}%K{001}%~$N%F{011}%K{004}%%%F{015}%K{000} "
g(){
[[ ${@:-1} = , ]] &&{ ((HIDIRF=1-HIDIRF));((#>1)) &&set -- ${@:1:-1}}
IFS=$'\n'
d=(`dirs -pl`)
DIRST=(${d:1})
case $1 in
.) pushd -0;;
-) pushd ~-;;
1)	popd 2>/dev/null;;
0) for m in $DIRST ;{ pushd "$m"};;
0[1-9]*-) n=${1%-}; while popd +$n 2>/dev/null ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for ((i=n-m;i>=0;--i)) ;{ popd +$m 2>/dev/null ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd +$((n-i++)) 2>/dev/null ||break};;
00) dirs -c;PS1="%F{015}%K{001}%~$N%F{011}%K{004}%%%F{015}%K{000} ";return;;
[1-9]|[1-9][0-9])
 m=;[ -d "$1" ]&&{
  m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/, since no index $1 in directory list"
 }
 if 2>/dev/null pushd "${DIRST[$1]}";then echo -ne $m>&2
 else [[ $m ]] &&{ pushd "$1";echo $n>&2}
 fi;;
,) if ((HIDIRF)) ;then
  echo NOW DIRECTORY STACK LIST IS HIDDEN>&2
  PS1="%F{015}%K{001}%~$N%F{011}%K{004}%%%F{015}%K{000} "
 else PS1="$DIRS%F{015}%K{001}%~$N%F{011}%K{004}%%%F{015}%K{000} ";fi
 return;;
$PWD)return;;
?*)
 if type -a "$1" 2>/dev/null;then F=1
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's a name of an executable too"
   read -N1 -p 'Is it an executable or directory name (which must be appended with / on CLI) ? (x / ELSE KEY) ' o
   [[ $o = [xX] ]] ||{ pushd  $1;F= }}
  ((F)) &&{
   x=$1;shift;args=;DNO=
   [[ $1 = . ]] &&{ args=\ ${DIRST: -1};shift}
   for m;{
    if [[ $m = -- ]] ;then DNO=1
    elif [[ $m =~ "^-(/.*)?$" ]];then
     args=$args\ ~-${match[1]}
     [[ $m = */ ]] && vared -p $x args
    elif [[ $m != -* ]] || ((DNO)) && [[ $m =~ "^([^1-9]*)([1-9][0-9]*)(.*)" ]] ;then
     f=${match[1]}
     n=${match[2]}
     b=${match[3]%/}
     if [[ $b =~ "^$|^//." ]] ;then
      args=$args\ $f$n${b/\/\//\/}
     else
      if ((n<=$#DIRST)) ;then
       args=$args\ $f$DIRST[n]$b
       [[ $m = */ ]] && vared -p $x args
      else
       echo -n "In '$m', $n is out of dir. stack range"
       [[ -d $m ]] && echo ", while it's a directory. Will not proceed"
       echo -e "\nTo predetermine a number in argument is a directory, append '/' on CLI:\n'$f$n/$b'"
       continue
      fi
     fi
    else args=$args\ $m;fi
   }
   echo -e "\n$x$args">&2
   eval "$x$args">&2
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
  d="$d%F{015}%K{001}${match[1]}%F{010}%K{000} ${match[2]}%F{0015}%K{000} "
 done
}< <(dirs -v)
 N=$'\n'
 DIRS=${d:+$d$N}
 if ((HIDIRF)) ;then echo ..HIDING DIRECTORY STACK LIST>&2;D=
 else D=$DIRS ;fi
 PS1="$D%F{015}%K{001}%~$N%F{011}%K{004}%%%F{015}%K{000} "
}>/dev/null
