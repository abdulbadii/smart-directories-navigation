# Bash smart directories navigation   
Go or get into a directory, keeping every previous directory saved, listed neatly right off on shell   
It must be inside ~/.bashrc to get the executable g (stand for get in) functioning, working directly, nicely and fast in shell terminal and no _DIRS and _DRS shell variable writing else    
Simply rename function name g with whatever you like; j, stand for jump into or b, stand for be in, etc    

# Usage   
Note on explanation below, each usage that means: *go to a directory* (i.e. not its removal from dir. stack, etc), the first step *save the current directory onto top of dir. stack* is implied before the first one explicitly written, except the `g 1` usage   

g   
go to $HOME dir.   

g -   
go back to the last dir. from where previously working directory, if top of the list was not just removed, simply it'd be it and will be identical to `g .` behavour   

g .   
go to directory on top of stack which is the first of dir. list (as opposed to g 1 below)     

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

likewise go to given directory namedly foo performing the first `g {directory}` usage, only now to be clearer that it may be in repetition form, withg all the rest put in dir. stack   
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
refresh i.e. update the prompt string of dir. stack which is cleaned up from any duplicate and inexistant directory   

g [a g option/command]  0  
toggle hiding or showing the directory stack list ouput on the prompt string   
if an optional command given, execute it first before the toggling, if it is to hide it'd still lastly be shown the list after which it'd be hidden on the next command prompt   
so naturally, `g 0` is merely to toggle hide or show the directory stack list, not at all going into $HOME directory first   

g --[n]   
retrieve any directory path written within the last 3 (or a specified n) lines of command history, or if it's non directory then get its directory in which it is, so to push them repetitively in the way already described above i.e. the most recent one being the current directory    

g \<a shell command line\>   
argument is any CLI with an executable whose argument(s) can be obtained from the dir. stack by which it is referenced   
on purpose of get more its various selection and navigation, append // to the argument. This won't make it immediately executed, instead it'd get into readline which will be ready to do what Bash command prompt will, e.g: modify argument path or string, making use of auto completion, etc

## This'd be the most useful feature which would be perfected with its auto completion capability by copying file Bash_auto-completion into ~/.bashrc
