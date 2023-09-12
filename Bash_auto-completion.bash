dircomp(){
local -n CWidx=COMP_CWORD words=COMP_WORDS
local now=${words[CWidx]} pre=${words[CWidx-1]} TYP=-d
((CWidx>1)) &&type -t -- ${words[1]} &&TYP=-f
IFS=$'\n'
if [[ $now = ../* ]] ;then
 COMPREPLY=( $(compgen -W '$(compgen $TYP ../)' $now) )
elif [[ $now =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]] ;then
 f=${BASH_REMATCH[1]}
 b=${BASH_REMATCH[3]}
 n=${BASH_REMATCH[2]}
 u=${DIRSTACK[n]}
 if [[ -d $f$n ]] &&[[ $b = @(/|//[!/]*) || -z $u ]] ;then
  b=${b#/}
  COMPREPLY=( $(compgen -d $f$n/${b#/}) )
 elif [[ $u ]] ;then
   u=$f$u
   COMPREPLY=( $(compgen -d $u$b/) )
 fi
elif [[ $now ]]  ;then
  COMPREPLY=( $(compgen -o dirnames $TYP -- $now) )
else
  exec 3< <(dirs -l -p)
  compopt -o nosort
  COMPREPLY=( $(read -u3;while read -u3 d; f=$?;read w || ((! f)) ;do echo ${d// /\\ }${d:+/};echo ${w// /\\ }${w:+/} ;done< <(compgen -d)
  if((CWidx==1)) ;then compgen -c; else for n in *;{ [[ -f $n ]] &&printf %s\\n "$n" ;};fi ) )
  exec 3>&-
fi
} &>/dev/null &&complete -o default -o nosort -F dircomp g


