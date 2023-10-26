dircomp(){
local -n CWidx=COMP_CWORD words=COMP_WORDS
local F G now=$2 T=-d IFS=$'\n'
((CWidx>1)) &&[[ $(type -t -- ${words[1]}) ]] &&T=-f
case $now in
../*) compopt -o plusdirs;COMPREPLY=( $(compgen -X "../${PWD##*/}" $T $now) );;
?([!1-9]*/)[1-9]?([0-9])*)
  compopt -o plusdirs
  [[ $now =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]]
  f=${BASH_REMATCH[1]}
  n=${BASH_REMATCH[2]}
  b=${BASH_REMATCH[3]}
  if [[ $f || $b = @(/|//[!/]*) ]] || ((n>=${#DIRSTACK[@]})) ;then
   [[ -d $f$n ]] &&{ b=${b#/}; COMPREPLY=( $(compgen -d $f$n/${b#/}) );}
  else
   COMPREPLY=(  $(compgen -d $f${DIRSTACK[n]}$b) )
  fi;;
*) COMPREPLY=( $(exec 3< <(dirs -l -p);read -u3
 while :;do
  ((!F)) &&{
   if read w
   then echo ${w// /\\ }/
   else ((G))&&break;F=1;fi
 }
  ((!G)) &&{
   if read -u3 d
   then [[ $d = $now* ]] &&echo ${d// /\\ }/
   else ((F))&&break;G=1;exec 3>&-;fi
  }
 done< <(compgen -d -- $now)
 ((CWidx==1)) &&compgen -c -- $now) )
esac
} &>/dev/null &&complete -o default -o nosort -F dircomp g


