PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
case $1 in
.)	pushd -0;;
-)	pushd ~-;;
$PWD) :;;
1)	popd 2>/dev/null;;
0) set -- ${DIRSTACK[@]}; for i;{ pushd "$i" ;};;
0[1-9]*-) n=${1%-}; while popd +$n 2>/dev/null ;do :;done;;
0[1-9]*-[1-9]*) m=${1%-*};n=${1#*-}; for((i=n-m;i>=0;--i)) ;{ popd +$m 2>/dev/null ;};;
0[1-9]*) i=;for n;{ [[ $n = 0[1-9] ]] ||break; popd +$((n-i++)) 2>/dev/null ||break;};;
00) dirs -c;DIRS=;return;;
[1-9]|[1-9][0-9])
 m=;[ -d "$1" ]&&{
  m="Directory $1/ exists, if it's meant instead, append character '/' on CLI: m $1/\n"
  n="Into directory $1/, since no index $1 in directory list"
 }
 if 2>/dev/null pushd ${DIRSTACK[$1]};then echo -ne $m>&2
 else [[ $m ]] &&{ pushd "$1";echo $n>&2;}
 fi;;
?*)
 type -a "$1" 2>/dev/null&&{
   F=1
   [[ -d $1 ]] &&{
    echo "'$1' is a directory in the working dir. but it's a name of an executable too"
    read -pN1 'Which one is it meant, a directory or an executable (append '/' on CLI to mean it directory)? (d/x) ' o
    [[ $o = d ]] && F=
   }
   ((F)) &&{
    exe=$1;args=;shift
    for m;{
     if [[ $m =~ ^([^1-9]*)([1-9][0-9]?)(.*) ]] ;then
      f=${BASH_REMATCH[1]}
      n=${BASH_REMATCH[2]}
      b=${BASH_REMATCH[3]}
      if [[ $b =~ ^//.|[^/]/$ ]] ;then
       dirn=$f$n${b%/}
       [[ -d $dirn ]] ||{ echo "Cannot stat '$dirn'">$2;return 1;}
       args=$args\ $dirn
      else
       dirn=$f${DIRSTACK[$n]}${b%//}
       if [[ $b = *// ]] ;then
        read -ei "$dirn" m
        args=$args\ $m
       else
        if ((n>${#DIRSTACK[@]})) ;then
         if [[ -d $m ]] ;then
          echo "'$n' in '$m' path is refered to real directory not dir. stack index"
          args=$args\ $m
         else "$n is out of dir. stack range";return 1;fi
        else args=$args\ $dirn ;fi
       fi
      fi
     else args=$args\ $m;fi
     }
     eval "$exe $args"
    return;}
}
 CD=$PWD
 i=$#
 if ((i>1)) ;then
  while ((i)) ;do
   eval "n=\${$((i--))}"
   if [[ $n = /* ]] ;then [[ -d $n ]] &&pushd "$n" 
   else [[ -d $CD/$n ]] &&pushd "$CD/$n";fi
  done
  pushd -0;pushd ~-
 else pushd $1 ;fi;;
*) [[ $HOME = $PWD ]] || pushd ~
esac
IFS=$'\n'
l=`dirs -l -p`
l=$'\n'${l//$'\n'/$'\n\n'}$'\n'
unset o d DIRS
while :
do set -- $l
	l=${l//$'\n'$1$'\n'}
 [[ $l ]] || break
 o="'$1' $o"
done
cd $1
dirs -c
unset IFS;eval set -- $o;for i ;{ pushd "$i" ;}
{ read l
while read l;do
 [[ $l =~ ^([1-9]+)\ +(.+) ]]
 d="$d \e[41;1;37m${BASH_REMATCH[1]}\e[40;1;32m${BASH_REMATCH[2]}\e[m"
done
}< <(dirs -v);
[ -n "$d" ] && export DIRS="${d# }\n\r"
}>/dev/null
