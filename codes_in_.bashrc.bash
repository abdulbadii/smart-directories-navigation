PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
local C DNO F D args d f b m n i o x
exec 3>&1
{
[[ ${!#} = 0 ]] &&{ ((HIDIRF=1-HIDIRF));(($#>1)) &&set -- ${@:1:(($#-1))};}
case $1 in
0[1-9]*-) n=${1%-}; while popd +$n ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for((i=n-m;i>=0;--i)) ;{ popd +$m ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9]* ]] ||break; popd +$((n-i++)) ||break;};;
 0) if ((HIDIRF)) ;then echo NOW DIRECTORY STACK LIST IS HIDDEN>&3;_DIRS=
  else _DIRS=$_DRS ;fi;return;;
-c) dirs -c;_DIRS=;  shift;(($#))&&m "$@";return;;
--?([4-9]|[1-9][0-9])) n=${1#--}
 C=$PWD
 while read -r m
 do eval set -- $m
   for i;{
     [[ $i =~ /?[a-z]+(/[a-z]+)* ]] &&{
      [[ $i = /* ]] || i=$C/$i
      if [[ -d $i && $i != $C ]] ;then pushd -n "$i"
      else i=${i%/*}; [[ -d $i && $i != $C ]] &&pushd -n "$i" ;fi
     };}
 done< <(history $((${n:=3}+1))); pushd;;
,,);;
-r) pushd;n=${#DIRSTACK[@]};for((i=2;i<n;));{ pushd "${DIRSTACK[i]}";popd +$((++i));};;
?*)
if [[ `type -t -- $1` && $1 != . && $2 ]] || [[ $1 = . && -f $2 ]] ;then {
  F=1
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's a name of an executable too"
   read -N1 -p "Is it meant as executable or directory name which should've had suffix / on CLI?  (x / ELSE KEY) " o
   [[ $o = [xX] ]] ||{ pushd "$1";F=;}
  }
  ((F)) &&{
   x=$1;shift
   args=;DNO=
   for m;{
    if [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]] ;then
     f=${BASH_REMATCH[1]}
     b=${BASH_REMATCH[3]}
     n=${BASH_REMATCH[2]}
     if [[ $b = @(/|//[!/]*) ]] ;then args=$args\ $f$n${b/\/\//\/}
     else
      if ((n<${#DIRSTACK[@]})) ;then
       args=$args\ $f${DIRSTACK[n]}${b%/}
       [[ $b = *// ]] &&{
        echo -n $x; read -ei "$args" args;args=\ $args;}
      else
       echo "$n is out of range. Aborted. To mean it as literal name, append '/' on CLI:  '$f$n/$b'";return
      fi
     fi
    else [[ $m = -- ]] &&DNO=1; args=$args\ $m;fi
   }
   echo -e "\e[1;37m$x$args\e[m"
   eval "$x$args"
  }
  }>&3 2>&3
elif (($#==1)) &&[[ $1 =~ ^[1-9][0-9]?(/)?$ ]] ;then
 if [[ ${BASH_REMATCH[1]} ]] ;then pushd $1 ||echo $1/ is not a directory>&3
 elif (($1==1)) ;then popd
 else
  m=;[[ -d $1 ]]&&{
  m="Directory $1/ exists, to mean it instead, append character / on CLI:  $1/\n"
  n="Into directory $1/ since no index $1 in directory list\n";}
  u=${DIRSTACK[$1]}
  if [[ $u ]] ;then pushd "$u";popd +$(($1+1))
  elif [[ $m ]] ;then pushd $1;m=$n
  else m="No index $1 in directory list nor the directory $1/ exists\n";fi
  echo -en "$m">&3
 fi
else
  F=;D=1; C=$PWD; i=$#
  if [[ $1 = [-.,] ]] ;then n=
   if [[ $1 = - ]] ;then n=-;elif [[ $1 = , ]] ;then n=-0;fi
   pushd $n;pushd +1
  else F=1;fi
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
     2>&3 read -N1 -t 2.5 -p "But under existing directory '$n', put it on stack? (n: No. ELSE/DEFAULT: Yes) " o &&
      [[ $o = n ]] &&{ echo;continue;}
      echo
     }>&3
   }
   if ((i)) ;then pushd -n "$n"
   else
     if ((F)) ;then pushd "$n" ;else pushd -0 ;fi; D=;break
   fi
  done
  ((D&&!F)) &&pushd
fi;;
*) [[ $HOME = $PWD ]] ||pushd ~
esac
IFS=$'\n'
d=`dirs -l -p`
d=$'\n'${d//$'\n'/$'\n\n'}$'\n'
o=
while :
do set -- $d
	d=${d//$'\n'$1$'\n'}
 [[ $d ]] || break
 o="'$1' $o"
done
pushd "$1"
dirs -c
unset IFS C d
eval set -- $o
for o;{ pushd "$o" 2>&3 ||C="$C, '$o'";}
}&>/dev/null
exec 3>&-
[[ $C ]]&&echo "Supposedly, but not being kept in dir. stack:${C#,}"
{
  read l; while read l
  do [[ $l =~ ^([1-9][0-9]?)[[:space:]]+(.+) ]]
   d="$d\e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m "
 done
}< <(dirs -v)
_DRS=$(echo -e "${d:+${d% }\n\r}")
_DIRS=$_DRS
((HIDIRF)) &&{ echo -n "${_DRS@P}"; _DIRS=;}
}
