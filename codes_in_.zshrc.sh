PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
g(){
[[ ${@: -1} = , ]] &&{ ((HIDIRF=1-HIDIRF));((#>1)) &&set -- ${@:1:-1} }
IFS=$'\n'
d=(`dirs -pl`);DIRST=(${d:1})
{
case $1 in
0[1-9]*-) n=${1%-}; while popd +$n;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for ((i=n-m;i>=0;--i)) ;{ popd -q +$m };;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd -q +$((n-i++)) ||break };;
[1-9]|[1-9][0-9])
 m=;[ -d "$1" ]&&{
  m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/, since no index $1 in directory list"
 }
 if (($1==1)) ;then popd -q; echo -ne $m
 elif pushd -q "$DIRST[$1]";then popd -q +$(($1+1)); echo -ne $m
 else
  [[ $m ]] &&{ pushd -q "$1";echo $n}
 fi;;
-c) dirs -c;PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k ";return;;
-r) for m in $DIRST ;{ pushd -q "$m"};;
,) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN
  PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
 else PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k ";fi;return;;
,,);;
?*)
 if [[ `whence "$1"` && $1 != . && -e $2 ]] || ([[ $1 = . && -f $2 ]]) ;then F=1
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
 F=;D=1;C=$PWD; i=$#
 if [[ $1 = . ]] ;then :
 elif [[ $1 = - ]] ;then  pushd -q ~-; pushd -q +1
 elif [[ $1 = 0 ]] ;then  pushd -q; pushd -q +1
 else F=1 ;fi
 pushd -q +1
 while n=${(P)i}; ((i--)) ;do
  n=${n%/}
  [[ $n != /* ]] && n="$C/$n"
  [[ $n = $C ]] &&continue
  [[ -d $n ]] ||{ ((F || i )) &&{
    echo "'$n' is not an existing directory"
    n=${n%/*}
    [[ -d $n ]] ||{ echo "Neither is '$n'";continue;}
    [[ $n = $C ]] &&continue
    read -k1 "?But written under existing directory '$n', put it on stack? (n: No. ELSE KEY: Yes) " o;echo
    [[ $o = n ]] &&continue
    }
  }
  if (( i )) ;then pushd -q "$n"
  else
   pushd -q -0
   if ((F)) ;then pushd -q "$n" ;else pushd -q -0 ;fi
   D=;break
  fi
 done
 ((D)) &&{ pushd -q -0;pushd -q }
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
}
 #2>/dev/null
C=;for o;{ pushd -q "$o" ||C="$C, '$o'" }
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
