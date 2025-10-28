PS1='$_DIRS\[\e[41;1;37m\]\w\[\e[m\]\n\[\e[40;1;33m\]\$\[\e[m\] '
g(){
local C DNO F D arg args d f b m n i o x RE=1
exec 3>&1
{
[[ ${!#} = -0 ]] &&{
 ((HID=1-HID))
 if ((HID)) ;then
  { echo -ne "DIRECTORY STACK LIST IS HIDDEN NOW\r";sleep 1.1;echo -ne "\e[K" ;}>&3
  _DIRS=
 else _DIRS=$_DRS ;fi
 (($#==1)) && return 0
 set -- ${@:1:(($#-1))}
}
case $1 in
-c) dirs -c;_DIRS=;  shift;(($#))&&m "$@";return;;
-[1-9]*([0-9])) i=;for n;{ popd +$((${n#-}-i++)) ||break;};;
-[1-9]*([0-9])-) n=${1//-}; while popd +$n ;do :;done;;
-[1-9]*([0-9])-[1-9]*([0-9]))
	m=${1%-*}; m=${m#-}
	n=${1##*-}
	for((i=n-m; i>=0; --i)) ;{ popd +$m ;};;
--?([1-9]*([0-9]))) n=${1#--}
 C=$PWD
 while read -r m
 do eval set -- $m
   for i;{
     [[ $i =~ /?[a-z]+(/[a-z]+)* ]] &&{
      [[ $i = /* ]] || i=$C/$i
      if [[ -d $i && $i != $C ]] ;then pushd -n "$i"
      else i=${i%/*}; [[ -d $i && $i != $C ]] &&pushd -n "$i" ;fi
     };}
 done< <(history $((${n:=49}+1))); pushd;;
,,);;
-r) pushd;n=${#DIRSTACK[@]};for((i=2;i<n;));{ pushd "${DIRSTACK[i]}";popd +$((++i));};;
?*)
  F=1
if [[ $(type -t -- $1) && $2 && $1 != . ]] || [[ $1 = . && -f $2 ]] ;then {
  [[ -d $1 ]] &&{
   echo "'$1' is a directory in the working dir. but it's an executable name too"
   read -N1 -p "Is it meant as executable or directory name (to mean so append '/' in CLI) ?  (x or ELSE KEY) " o
   [[ $o = [xX] ]] ||{ pushd "$1";F=;}
  }
  ((F)) &&{
   x=$1;shift
   args=();DNO=
   for m;{
    if [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^0-9]*/)?([0-9][0-9]?)(.*) ]] ;then
     f=${BASH_REMATCH[1]}
     b=${BASH_REMATCH[3]}
     n=${BASH_REMATCH[2]}
     if [[ $b = @(/|//[!/]*) ]] ;then args+=(\'$f$n${b/\/\//\/}\')
     else
      if ((n<${#DIRSTACK[@]})) ;then
       args+=(\'$f${DIRSTACK[n]}${b%/}\')
       [[ $b = *// ]] &&{
        echo -n $x; read -ei "${args[@]}" arg; args=($arg)
        }
      else echo "$n is out of dir. stack range. Aborted. To mean it as literal name, append '/' at the end:  '$f$n/$b'";return
      fi
     fi
    else [[ $m = -- ]] &&DNO=1; args+=(\'$m\');fi
   }
   h=($x ${args[@]})
   echo -e "\e[1;37m${h[@]}\e[m";eval ${h[@]}
   history -d -1
   history -s ${h[@]}
  }
  }>&3 2>&3
elif (($#==1)) &&[[ $1 =~ ^[0-9][0-9]?(/)?$ ]] ;then
 if [[ ${BASH_REMATCH[1]} ]] ;then pushd $1 ||echo $1/ is not a directory>&3
 elif (($1==1)) ;then popd
 else
  m=;[[ -d $1 ]]&&{
  m="Directory $1/ exists, to mean it instead, append character / on CLI:  $1/\n"
  n="Into directory $1/ since no index $1 in directory list\n";}
  u=${DIRSTACK[$1]}
  if [[ $u ]] ;then pushd "$u";((RE= $? & RE)); popd +$(($1+1))
  elif [[ $m ]] ;then pushd $1;((RE= $? & RE)) ;m=$n
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
   if ((i)) ;then pushd -n "$n" ;((RE= $? & RE))
   else D=
     if ((F)) ;then pushd "$n" ;else pushd -0 ;fi ;((RE= $? & RE))
     break
   fi
  done
  ((D&&!F)) &&pushd
fi;;
*) [[ $PWD = $HOME ]] ||{ pushd ~; (( RE=$? &RE)) ;}
esac
[[ ${DIRSTACK[1]} = /home/$USER ]] &&popd +1 
o=;IFS=$'\n'
d=`dirs -l -p`
d=$'\n'${d//$'\n'/$'\n\n'}$'\n'
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
for o;{	pushd "$o" 2>&3 ||C="$C, '$o'" 
}
} &>/dev/null
exec 3>&-
[[ $C ]]&&echo "Directory that's gone:${C#,}"
{
  read l; while read l
  do [[ $l =~ ^([1-9][0-9]?)[[:space:]]+(.+) ]]
   d="$d\e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m "
 done
}< <(dirs -v)
_DRS=$(echo -e "${d:+${d% }\n\r}")
_DIRS=$_DRS
((HID)) &&{ echo -n "${_DRS@P}"; _DIRS=;}
return $RE
}
