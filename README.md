# Bash smart directories navigation   
Go or get into a directory, keeping every previous directory saved, listed neatly right off on shell   
It must be inside ~/.bashrc to have the function g (stand for get in) working nicely, fast in Linux shell terminal provided that no other _DIRS and _DRS shell variables writing    
So just rename function name g to whatever you like; j (jump into), or b (be in), etc    

# Usage   
Note on explanation below, each usage that means: *go to a directory*, i.e. not its removal from dir. stack, etc, implies the first step *save the current directory onto top of dir. stack* before the following explicit steps explanation except on `g 1` (its usage informed below) and except if current working directory is user home since `g <ENTER>` is simpler

g   
go to $HOME directory   

g .   
go to directory on top (the first) of directory stack as opposed to g 1 below     

g 1   
like above, but renouncing, i.e. not retaining, current directory    

g -   
go back to the previous working directory. If top of the list was not just removed, simply it'd be it and will be identical to `g .` behavour   

g ,   
go to the last of dir. stack whose index is the greatest   

g {nth}   
go to the nth index of dir. stack with behavour exception is index 1 explained above   

g {directory_name}   
go to the "directory_name". For numerical name, suffix it with **/** to prevail over a existing dir. stack index number   

g [. | - | ,] foo \[bar baz ...\]    

likewise go to given directory named **foo**, if any extra one(s) following, they are all put in dir. stack   
it may optionally be preceded by . or - or , which would be accomplished first   

g -{n}[-[{n}]] | --{n} ...  
remove every given dir. stack nth index either by single one(s) or range(s)   

g -c   
clean up all dir. stack   

g -r   
reverse the dir. index order and go to the last of dir. stack

g ,,   
Do nothing. It's only made use to refresh, update the prompt string of dir. stack which is cleaned up from any duplicate and inexistant directory   

g [g command] -0  
toggle hiding or showing the directory stack list ouput on the prompt string   
if an optional command given, execute it first before the toggling, if it is to hide it'd still lastly be shown the list after which it'd be hidden on the next command prompt   
so naturally, `g -0` is merely to toggle hide or show the directory stack list, not at all going into $HOME directory first   

g -h[n]   
retrieve any directory path saved in the last 49, or n number specified, lines of command history. If it's a path to non directory object, get its directory, then push them all repetitively in the way that the most recent one being the current directory    

g \<a shell command line\>   
argument is a CLI with the first is an executable name whose argument(s) can be obtained from the dir. stack by which it is referenced   
on purpose of get more its various selection and navigation, append // to the argument. This won't make it immediately executed, instead it'd get into readline which will be ready to do what Bash command prompt will, e.g: modify argument path or string, making use of auto completion, etc

#### This'd be the most useful feature which would be perfected with its auto completion capability   
by copying file Bash_auto-completion into ~/.bashrc   
