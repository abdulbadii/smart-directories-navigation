# Bash smart directories navigation   
Go or get into a directory, keeping every previous directory saved, listed neatly right off on shell   
It must be inside ~/.bashrc to get the executable g (stand for get in) functioning, working directly, nicely and fast in shell terminal and no DIRS shell variable else being used    
Simply rename function name g with whatever you like; j, stand for jump into or b, stand for be in, etc    

# Usage   
Note explanation below that each usage to mean: go to a directory, i.e. not its removal from dir. stack, the first process step "save the current directory onto top of dir. stack" is implied before the first one explicitly written, except the `g 1` usage   

g   
go to $HOME dir.   

g -   
go back to the last dir. you went from which is 1st index of dir. stack (as opposed to g 1 below)   

g .   
go to the earliest dir. which is the deepest dir. on dir. stack   

g 0   
reverse the dir. index order and get into the earliest dir.   

g {nth}   
go to the nth index of dir. stack, exception is index 1 by g 1 below

g 1   
go to directory pointed by the top of dir. stack and lose the current directory, use `g -` otherwise to keep current dir at top of dir. stack    

g {directory_name}   
go to the "directory_name" dir. For numerical name, suffix it with / to prevail over existing same index number of dir. stack

g foo bar...   
go to first of the listed dir. given, foo, while the rest of list is put in dir. stack    

g 0{nth}...  
remove every given nth index of dir. stack   

g 0{nth}-  
remove the nth index and every dir. greater than it of dir. stack   

g 0{nth}-{Nth}  
remove every dir. index in the range nth to Nth index of dir. stack   

g 00   
clean up all dir. stack   

g \<Bash command line\>   
Any CLI with an executable whose argument can be obtained from the dir. stack being referenced   
For the purpose of get more its various selection, append // to the argument. This won't make it immediately executed, instead it'd get into readline which is ready to do what Bash command prompt is, e.g: modify the argument string, (executable) path auto completion, etc

