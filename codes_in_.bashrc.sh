PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
exec 3>&1
{
[[ ${!#} = , ]] &&{ ((HIDIRF=1-HIDIRF));(($#>1)) &&set -- ${@:1:(($#-1))};}
case $1 in
0[1-9]*-) n=${1%-}; while popd +$n ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for((i=n-m;i>=0;--i)) ;{ popd +$m ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd +$((n-i++)) ||break;};;
[1-9]|[1-9][0-9])
 m=;[[ -d $1 ]]&&{
  m="Directory $1/ exists, to mean it instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/\nsince no index $1 in directory list\n";}
 if (($1==1)) && popd;then :
 elif pushd "${DIRSTACK[$1]}";then popd +$(($1+1))
 elif [[ $m ]] ;then pushd "$1"; m=$n
 else m='No index $1 in directory list nor the directory exists\n';fi
 echo -ne $m>&3;;
-c) dirs -c;_DIRS=;return;;
-r) for i in ${DIRSTACK[@]};{ pushd "$i" ;};;
 ,) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN>&3;_DIRS=
  else _DIRS=$_DRS ;fi;return;;
,,);;
?*)
 if [[ `type -t "$1"` && $1 != . && -e $2 ]] || ([[ $1 = . && -f $2 ]]) ;then F=1
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's a name of an executable too">&3
   read -N1 -p 'Mean it as an executable or directory name (Predetermine by appending / on CLI) ? (x / ELSE KEY) ' o
   [[ $o = [xX] ]] ||{ pushd $1;F=;}
  }
  ((F)) &&{
   x=$1;shift;args=;DNO=
   [[ $1 = . ]] &&{ args=\ ${DIRSTACK[@]: -1};shift;}
   for m;{
    [[ $m = -- ]] && DNO=1
    if [[ $m =~ ^-(/.*)?$ ]];then
     args=$args\ ~-${BASH_REMATCH[1]}
     [[ $m = */ ]] &&{ echo -n $x>&3;read -ei "$args" args;args=\ $args;}
    elif [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^1-9]*)([1-9][0-9]?)(.*) ]] ;then
     f=${BASH_REMATCH[1]}
     n=${BASH_REMATCH[2]}
     b=${BASH_REMATCH[3]%/}
     if [[ $b =~ ^$|^//. ]] ;then args=$args\ $f$n${b/\/\//\/}
     else
      if ((n<=${#DIRSTACK[@]})) ;then
       args=$args\ $f${DIRSTACK[n]}$b
       [[ $m = */ ]] &&{ echo -n $x>&3;read -ei "$args" args;args=\ $args;}
      else
       echo -n "In '$m', $n is out of dir. stack range"
       [[ -d $m ]] && echo ", while it's a directory. Not proceeding it"
       echo -e "\nTo predetermine a number in argument is a directory, append '/' on CLI:\n'$f$n/$b'"
       continue
      fi
     fi
    else args=$args\ $m;fi
   }
   echo -e "\n$x$args">&3
   eval "$x$args">&3
  }
else
 F=;D=1;C=$PWD i=$#
 if [[ $1 = [-.0] ]] ;then n=
  if [[ $1 = - ]] ;then n=-
  elif [[ $1 = 0 ]] ;then n=-0;fi
  pushd $n
  pushd +1
 else F=1
 fi
 while n=${!i}; ((i--)) ;do
  n=${n%/}
  : ${n:=/}
  [[ $n != /* ]] && n="${C%/}/$n"
  [[ $n = $C ]] &&continue
  [[ -d $n ]] ||{ ((F || i )) &&{
    echo "'$n' is not a directory"
    n=${n%/*}
    [[ ! -d $n ]] &&{ echo "Neither is '$n'";continue;}
    [[ $n = $C ]] &&continue
    read -N1 -p "But written under existing directory '$n', put it on stack? (n: No. ELSE KEY: Yes) " o;echo
    [[ $o = n ]] &&continue
    }>&3
  }
  if (( i )) ;then pushd -n "$n"
  else
     if (( F )) ;then pushd "$n" ;else pushd -0 ;fi
     D=;break
  fi
 done
 ((D)) && pushd
fi;;
*) [[ $HOME = $PWD ]] ||pushd ~
esac
IFS=$'\n'
l=`dirs -l -p`
d=$'\n'${l//$'\n'/$'\n\n'}$'\n'
o=
while :
do set -- $d
	d=${d//$'\n'$1$'\n'}
 [[ $d ]] || break
 o="'$1' $o"
done
pushd $1
dirs -c
unset IFS C d
eval set -- $o
for o;{ pushd "$o" 2>&3 ||C="$C, '$o'";}
} &>/dev/null
exec 3>&-
[[ $C ]]&&echo "Supposedly, but not being kept in dir. stack:${C/,/}"
{
  read l; while read l
  do [[ $l =~ ^([1-9]+)\ +(.+) ]]
   d="$d\e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m "
 done
}< <(dirs -v)
_DRS=$(echo -e "${d:+$d\n\r}")
_DIRS=$_DRS
((HIDIRF)) &&{ echo -n "${_DRS@P}"; _DIRS=;}
}
