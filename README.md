# Bash smart directories navigation   
Go or get into a directory, keeping every previous directory saved, listed neatly right off on shell   
It must be inside ~/.bashrc to get the executable g (stand for get in) functioning, working directly, nicely and fast in shell terminal and no _DIRS and _DRS shell variable writing else    
Simply rename function name g with whatever you like; j, stand for jump into or b, stand for be in, etc    

# Usage   
Note on explanation below, each usage that has meaning: *go to a directory* (i.e. not its removal from dir. stack, etc), the first step "save the current directory onto top of dir. stack" is implied before the first one explicitly written, except the `g 1` usage   

g   
go to $HOME dir.   

g -   
go back to the last dir. from where previously working directory (as opposed to g 1 below), if top of the list was not just removed, simply it'd be it and will be identical to `g .` behavour   

g .   
go to directory on top of stack, that is the first in dir. list which has the index 1   

g 1   
like above, go to directory pointed by top of list, but will not have current directory retained   

g ,   
go to the last of dir. stack which has the greatest index   

g {nth}   
go to the nth index of dir. stack, exception is index 1 explained above, and 0 explained below   

g {directory}   
go to the "directory_name" dir. For numerical name, suffix it with / to prevail over existing same index number of dir. stack

g foo \[bar baz ...\]    

g . | - | ,  \[foo bar baz ...\]    

likewise go to the given name foo performing the first `g {directory}` usage, only now to be clearer that it may be in repetition form, withg all the rest put in dir. stack   
it may optionally be started with . or - or , options mentioned above which'd be accomplished first (the second form)   

g 0{nth} 0{nth} ...  
remove every given nth index of dir. stack   

g 0{nth}-  
remove the nth index and every dir. greater than it of dir. stack   

g 0{nth}-{Nth}  
remove every dir. index in the range nth to Nth index of dir. stack   

g -c   
clean up all dir. stack   

g -r   
reverse the dir. index order and go to the last of dir. stack

g ,,   
refresh i.e. update the prompt string of dir. stack which is cleaned up from duplicate and inexistant directories   

g [a g option/command]  0  
toggle hiding or showing the directory stack list ouput on the prompt string   
if an optional command given, execute it first before the toggling, then if it is to hide it'd still lastly show the list, and then hide it on the next command prompt   
so naturally, `g 0` is merely to toggle hide or show the directory stack list, not at all to go into $HOME directory first   

g \<a shell command line\>   
any CLI with an executable whose argument can be obtained from the dir. stack by which it is referenced   
on purpose of get more its various selection, append // to the argument. This won't make it immediately executed, instead it'd get into readline which will be ready to do what Bash command prompt will, e.g: modify argument path or string, making use of auto completion, etc

