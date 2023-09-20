dircomp(){
local -n CWidx=COMP_CWORD words=COMP_WORDS
local now=${words[CWidx]} pre=${words[CWidx-1]} T=-d
((CWidx>1)) &&type -t -- ${words[1]} &&T=-f
IFS=$'\n'
if [[ $now = ../* ]] ;then
 COMPREPLY=( $(compgen -W '$(compgen $T ../)' $now) )
elif [[ $now =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]] ;then
 f=${BASH_REMATCH[1]}
 b=${BASH_REMATCH[3]}
 n=${BASH_REMATCH[2]}
 if [[ $f || $b = @(/|//[!/]*) ]] || ((n>=${#DIRSTACK[@]})) ;then
  [[ -d $f$n ]] &&{
   b=${b#/}
   COMPREPLY=( $(compgen -d $f$n/${b#/}) );}
 else compopt -o nospace
  COMPREPLY=( "$f${DIRSTACK[n]// /\\ }$b" $(compgen -d $f${DIRSTACK[n]}$b/) )
 fi
elif [[ $now ]]  ;then
  COMPREPLY=( $(compgen -o dirnames $T -- $now) )
else
  exec 3< <(dirs -l -p)
  compopt -o nosort
  COMPREPLY=( $(read -u3;while read -u3 d; f=$?;read w || ((! f)) ;do echo ${d// /\\ }${d:+/};echo ${w// /\\ }${w:+/} ;done< <(compgen -d)
  if((CWidx==1)) ;then compgen -c; else for n in *;{ [[ -f $n ]] &&printf %s\\n "$n" ;};fi ) )
  exec 3>&-
fi
} &>/dev/null &&complete -o default -o nosort -F dircomp g


