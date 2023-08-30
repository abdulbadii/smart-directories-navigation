PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
g(){
[[ ${@: -1} = , ]] &&{ ((HIDIRF=1-HIDIRF));((#>1)) &&set -- ${@:1:-1} }
IFS=$'\n'
d=(`dirs -pl`);DIRST=(${d:1})
case $1 in
1)	popd -q 2>/dev/null;;
0[1-9]*-) n=${1%-}; while popd +$n 2>/dev/null ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for ((i=n-m;i>=0;--i)) ;{ popd -q +$m 2>/dev/null ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd -q +$((n-i++)) 2>/dev/null ||break};;
-r) for m in $DIRST ;{ pushd -q "$m"};;
-c) dirs -c;PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k ";return;;
[1-9]|[1-9][0-9])
 m=;[ -d "$1" ]&&{
  m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/, since no index $1 in directory list"
 }
 if 2>/dev/null pushd -q "$DIRST[$1]";then popd -q +$(($1+1)); echo -ne $m
 else [[ $m ]] &&{ pushd -q "$1";echo $n}
 fi;;
,) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN
  PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
 else PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k ";fi;return;;
,,);;
?*)
 if type -a "$1"&>/dev/null && [[ $1 != . ]] || ([[ $1 = . && -f $2 ]]) ;then F=1
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's a name of an executable too"
   read -k1 '?Is it an executable or directory name (which must be appended with / on CLI) ? (x / ELSE KEY) ' o
   [[ $o = [xX] ]] ||{ pushd -q  $1;F= }}
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
   echo -e "\n$x$args"
   eval "$x$args"
  }
else
 unset F DS DT
 C=$PWD;i=$#
 if [[ $1 = - ]] ;then
  if ((--i)) ;then shift;DS=1; pushd -q +1 ;else pushd -q ~-;fi
 elif [[ $1 = . ]] ;then
  if ((--i)) ;then shift;pushd -q +1;DT=1 ;else pushd -q -0;fi
 fi
 while n=${(P)i}; ((i--)) ;do
  [[ $n != /* ]] && n="$C/$n" 
  [[ -e $n ]] ||{ echo "cannot stat '$n'";continue}
  [[ -d $n ]] ||{
   echo "'$n' is not directory"
   n=${n%/*};n=$n/
   [[ ! -d $n || $n = $PWD ]] &&{ echo "Neither is '$n'";continue }
   read -k1 "?But witten under existing directory '$n', put it on stack? (n: No. ELSE KEY: Yes) " o;echo
   [[ $o = n ]] &&continue}
   F=1
   pushd -q "$n" 
 done
 if ((DS));then pushd -q -0;pushd -q
 elif ((DT));then pushd -q -1
 elif ((F*DS*DT));then pushd -q ;fi
fi;;
*) [[ $HOME = $PWD ]] ||pushd -q ~
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
pushd -q $1
dirs -c
eval set -- $=o
C=;for o;{ pushd "$o"&>/dev/null ||C=C="$C, '$o'" }
 [[ $C ]]&&echo "Supposedly, but not being kept in dir. stack:${C/,/}"
{
 read l
 d=;while read l
 do [[ $l =~ "^([1-9]+)\h+(.+)" ]]
  d="$d%F{015}%K{001}${match[1]}%F{010}%K{000}${match[2]}%f%k "
 done
}< <(dirs -v)
N=$'\n'
_DRS=${d:+$d$N}
if ((HIDIRF)) ;then echo ${(%%)d}
 PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
else
 PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
fi
}
