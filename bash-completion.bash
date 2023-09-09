local cword=$COMP_CWORD words=(${COMP_WORDS[@]}) now pre
now=${words[cword]}
pre=${words[cword-1]}
if type -t -- ${words[1]} ;then fileT=-f ;else fileT=-d ;fi
IFS=$'\n'
if [[ $now = ../* ]] ;then
 COMPREPLY=( $(compgen -W '$(compgen $fileT ../)' $now) )
elif [[ $now =~ ^([^1-9]*/)?([1-9][0-9]?)(.*) ]] ;then
 f=${BASH_REMATCH[1]}
 b=${BASH_REMATCH[3]}
 u=$f${DIRSTACK[BASH_REMATCH[2]]}$b
 COMPREPLY=( $(compgen -W "$(compgen $fileT $u)" $u) )
else
 exec 3< <(IFS=$'\n' dirs -l -p)
 COMPREPLY=( $(compgen -W "$(read -u3;while read -u3 d; f=$?;read w || ((! f)) ;do echo ${d// /\\\\ }${d:+/};echo ${w// /\\\\ }${w:+/} ;done< <(compgen -d);compgen -c)" $now) )
fi
} &>/dev/null &&complete -o default -o nosort -F _d m
