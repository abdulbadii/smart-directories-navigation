PS1='`echo -e "$DIRS"`\[\e[41;1;37m\]\w\[\e[40;1;33m\]\n\$\[\e[m\] '
g(){
case $1 in
.) pushd -0;;
-) pushd ~-;;
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
$PWD) :;;
?*)
 type -a "$1" 2>/dev/null&&{
   F=1
   [[ -d $1 ]] &&{
    echo "'$1' is a directory in the working dir. but it's a name of an executable too"
    read -N1 -p 'Is it meant as executable or a directory name (which next time append '/' to it on CLI)? (d / ELSE KEY) ' o
    [[ $o = [dD] ]] && F=
   }
   ((F)) &&{
    exe=$1;args=;DNO=;shift
    for m;{
     [[ $m = -- ]] && DNO=1
     if [[ $m != -* ]] || ((DNO)) && [[ $m =~ ^([^1-9]*)([1-9][0-9]?)(.*) ]] ;then
      f=${BASH_REMATCH[1]}
      n=${BASH_REMATCH[2]}
      b=${BASH_REMATCH[3]}
      if [[ $b =~ ^//.|^/$ ]] ;then
       b=${b#/};dirn=$f$n${b%/}
       [[ -d $dirn ]] ||{ echo "Cannot stat '$dirn'">&2;return 1;}
       args=$args\ $dirn
      else
        if ((n<=${#DIRSTACK[@]})) ;then
         dirn=$f${DIRSTACK[$n]}
         if [[ $m = *// ]] ;then echo -n $exe>&2;read -ei "$args $dirn" args
         else args=$args\ $dirn$b;fi
       else
         echo -n "In '$m', $n is out of dir. stack range"
         if [[ -d $m ]] ;then
          echo -e " while it's an existing directory\nIf it's really meant append '/' on CLI: '$f$n/$b'"
          read -N1 -p "So proceed with '$n' treated as the directory? (y / ELSE KY)" o
          [[ $o = [yY] ]] ||return 1
          args=$args\ $m
         else return 1;fi
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
[[ $d ]] && export DIRS="${d# }\n\r"
}>/dev/null
