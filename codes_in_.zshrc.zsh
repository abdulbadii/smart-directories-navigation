PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
g(){
[[ ${@: -1} = 0 ]] &&{ ((HIDIRF=1-HIDIRF));((#>1)) &&set -- ${@:1:-1} }
IFS=$'\n'
d=(`dirs -pl`);DIRST=(${d:1})
{
case $1 in
0[1-9]*-) n=${1%-}; while popd +$n;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for ((i=n-m;i>=0;--i)) ;{ popd -q +$m };;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd -q +$((n-i++)) ||break };;
-c) dirs -c;PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k ";return;;
-r) for m in $DIRST ;{ pushd -q "$m"};;
0) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN
  PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
 else PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k ";fi;return;;
,,);;
?*)
 if [[ `whence $1` && $1 != . && $2 ]] || ([[ $1 = . && -f $2 ]]) ;then
 F=1
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's a name of an executable too"
   read -k1 "?Is it meant as executable or directory name which should've had suffix / on CLI? (x / ELSE KEY) " o
   [[ $o = [xX] ]] ||{ pushd -q  $1;F= }}
  ((F)) &&{
   x=$1;shift
   args=;DNO=
   for m;{
    if [[ $m != -* ]] || ((DNO)) && [[ $m =~ '^([^1-9]*/)?([1-9][0-9]*)(.*)' ]] ;then
     f=$match[1]
     n=$match[2]
     b=$match[3]
     if [[ $b =~ '^/$|^//[^/]' ]] ;then args=$args\ $f$n${b/\/\//\/}
     else
      if ((n<=$#DIRST)) ;then
       args=$args\ $f$DIRST[n]${b%/}
       [[ $b = *// ]] && vared -p $x args
      else echo "$n is out of range. Aborted. To mean it as literal name, append '/' on CLI:  '$f$n/$b'";return
      fi
    fi
    else [[ $m = -- ]] &&DNO=1; args=$args\ $m;fi
   }
   echo -e "\e[1;37m$x$args\e[m"
   eval "$x$args"
  }
elif unset match; [[ $1 =~ '^[1-9][0-9]?(/)?$' ]] &&(($#==1)) ;then
 if [[ $match[1] ]] ;then pushd -q $1 ||echo $1 is not a directory
 elif (($1==1)) ;then popd -q
 else
  m=;[[ -d $1 ]]&&{
   m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
   n="Into directory $1/, since no index $1 in directory list"
  }
  u=$DIRST[$1]
  if [[ $u ]] ;then pushd -q "$u";popd -q +$(($1+1))
  elif [[ $m ]] ;then pushd -q $1;m=$n
  else m="No index $1 in directory list nor the directory $1/ exists";fi
  echo "$m"
 fi
else
 F=;D=1;C=$PWD; i=$#
 if [[ $1 = [-.,] ]] ;then n=
  if [[ $1 = - ]] ;then n=-
  elif [[ $1 = , ]] ;then n=-0;fi
  pushd -q $n
  pushd -q +1
 else F=1 ;fi
 pushd -q +1
 while n=${(P)i}; ((i--)) ;do
  n=${n%/}
  : ${n:=/}
  [[ $n != /* ]] && n="${C%/}/$n"
  [[ $n = $C ]] &&continue
  [[ -d $n ]] ||{ ((F || i )) &&{
    echo "'$n' is not a directory"
    n=${n%/*}
    [[ -d $n ]] ||{ echo "Neither is '$n'";continue;}
    [[ $n = $C ]] &&continue
    read -k1 -t 2.5 "?But written under existing directory '$n', put it on stack? (n: No. ELSE KEY: Yes) " o;echo
    [[ $o = [nN] ]] &&continue
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
} 2>/dev/null
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
_DRS=${d:+${d% }$N}
if ((HIDIRF)) ;then echo ${(%%)d}
 PS1="%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
else PS1="$_DRS%F{015}%K{001}%B%~%b$N%F{011}%K{004}%%%f%k "
fi
}
