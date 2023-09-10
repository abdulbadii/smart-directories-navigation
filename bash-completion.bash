dircomp(){
local -n cword=COMP_CWORD words=COMP_WORDS
local now=${words[cword]} pre=${words[cword-1]}
TYP=-d
((cword>1)) &&type -t -- ${words[1]} &&TYP=-f
IFS=$'\n'
if [[ $now = ../* ]] ;then
 COMPREPLY=( "$(compgen -W '$(compgen $TYP ../)' $now)" )
elif [[ $now =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]] ;then
 f=${BASH_REMATCH[1]}
 b=${BASH_REMATCH[3]}
 n=${BASH_REMATCH[2]}
 u=${DIRSTACK[n]}
 if [[ -d $n ]] &&[[ $b = @(/|//?*) || -z $u ]] ;then
   COMPREPLY=( "$(compgen -W '$(compgen $TYP $n/)' $n${b#/})" )
 elif [[ $u ]] ;then
   u=$f$u
   COMPREPLY=( "$(compgen -W '$(compgen $TYP $u/)' $u$b)" )
 fi
else
  exec 3< <(dirs -l -p)
  COMPREPLY=( $(compgen -W "$(read -u3;while read -u3 d; f=$?;read w || ((! f)) ;do echo ${d// /\\\\ }${d:+/};echo ${w// /\\\\ }${w:+/} ;done< <(compgen -d);compgen -c)" $now) )
fi} &>/dev/null &&complete -o default -o nosort -F dircomp m
