dircomp(){
shopt -s extglob
local -n CWidx=COMP_CWORD words=COMP_WORDS
local now=$2 pre=$3
IFS=$'\n'
if [[ $now = ../* ]] ;then
 COMPREPLY=( $(compgen -W '$(compgen -d ../)' $now) )
elif [[ $now =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]] ;then
 f=${BASH_REMATCH[1]}
 n=${BASH_REMATCH[2]}
 b=${BASH_REMATCH[3]}
 if [[ $b ]] ;then
  [[ -e ${now%/*} ]] &&
  COMPREPLY=( $(compgen -W "$(compgen -d ${now%/*})" -- "$now") )
 else 
  ((n<${#DIRSTACK[@]})) &&
  COMPREPLY=( "$f${DIRSTACK[n]// /\\ }$b" $(compgen -d $f${DIRSTACK[n]}$b/) )
 fi
elif [[ $now ]]  ;then
  COMPREPLY=( $(compgen -d "$now") )
else
  exec 3< <(dirs -l -p)
  compopt -o nosort
  COMPREPLY=( $(read -u3;while read -u3 d; F=$?;read w || ((!F)) ;do echo ${d// /\\ }${d:+/};echo ${w// /\\ }${w:+/} ;done< <(compgen -d)
  ((CWidx==1)) &&T=-c; compgen -d) )
  exec 3>&-
fi
}; complete -o nospace -o plusdirs -o default -F dircomp g
