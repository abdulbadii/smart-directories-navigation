PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
eval "n=\$$#"
[[ $n = , ]] &&{ ((HIDIRF=1-HIDIRF));(($#>1)) &&set -- ${@:1:(($#-1))}
}
case $1 in
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
 ,) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN>&2;DIRS=
  else DIRS=$DIRSB ;fi;return;;
$PWD)return;;
?*)
 if type -a "$1" 2>/dev/null &&[[ $1 != . ]];then F=1
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's a name of an executable too"
   read -N1 -p 'Is it an executable or directory name (which must be appended with / on CLI)? (x / ELSE KEY) ' o
   [[ $o = [xX] ]] ||{ pushd $1;F=;}
  }
  ((F)) &&{
   x=$1;shift;args=;DNO=
   [[ $1 = . ]] &&{ args=\ ${DIRSTACK[@]: -1};shift;}
   for m;{
    [[ $m = -- ]] && DNO=1
    if [[ $m =~ ^-(/.*)?$ ]];then
     args=$args\ ~-${BASH_REMATCH[1]}
     [[ $m = */ ]] &&{ echo -n $x>&2;read -ei "$args" args;args=\ $args;}
    elif [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^1-9]*)([1-9][0-9]?)(.*) ]] ;then
     f=${BASH_REMATCH[1]}
     n=${BASH_REMATCH[2]}
     b=${BASH_REMATCH[3]%/}
     if [[ $b =~ ^$|^//. ]] ;then args=$args\ $f$n${b/\/\//\/}
     else
      if ((n<=${#DIRSTACK[@]})) ;then
       args=$args\ $f${DIRSTACK[n]}$b
       [[ $m = */ ]] &&{ echo -n $x>&2;read -ei "$args" args;args=\ $args;}
      else
       echo -n "In '$m', $n is out of dir. stack range"
       [[ -d $m ]] && echo ", while it's a directory. Not proceeding it"
       echo -e "\nTo predetermine a number in argument is a directory, append '/' on CLI:\n'$f$n/$b'"
       continue
      fi
     fi
    else args=$args\ $m;fi
   }
   echo -e "\n$x$args">&2
   eval "$x$args">&2
  }
else D=1
 [[ $1 = [-.] ]] &&{ D=
  if [[ $1 = . ]];then pushd -0;else pushd ~-;fi;shift
 }
 i=$#;C=$PWD
 while ((i)) ;do
  eval "n=\${$((i--))}"
  [[ $n != /* ]] && n="$C/$n" 
  [[ -d $n ]] ||{ G=
   echo "'$n' is not directory">&2
   n=${n%/*};n=$n/
   [[ -d $n ]] ||continue
   if((i+D)) ;then G="Put directory '$n' onto stack"
   else G='Go to the directory '$n'';fi
   read -N1 -p "$G ? (n: No. ELSE KEY: Yes) " o;echo>&2
   [[ $o = n ]] &&continue;}
  pushd -n "$n"
 done
 ((D)) &&pushd
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
{ read l
 while read l
 do [[ $l =~ ^([1-9]+)\ +(.+) ]]
  d="$d\e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m "
 done
}< <(dirs -v)
DIRSB=$(echo -e "${d:+$d\n\r}")
if ((HIDIRF)) ;then echo ..HIDING DIRECTORY STACK LIST>&2;DIRS=
else DIRS=$DIRSB ;fi
}>/dev/null
