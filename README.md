# smart-directories-navigation
Bash smart directories navigation
go or get into a directory keeping the previous directory saved, listed neatly right off on shell
It must be inside ~/.bashrc to get the executable g, stand for get into, function working directly, nicely, fast in shell terminal and no DIRS shell variable else being used    
simply rename function name g with whatever you like; j (stand for jump into), b (stand for be in), etc    

# Usage   
Note all the go to a dir. uses, i.e. not removing one, the very first step: save the current dir. at top of dir. stack, is implied before any step explicitly written except g 1   

g   
go to $HOME dir.   
g -   
go back to the last dir. you went from which is 1st index of dir. stack (as opposed to g 1 below)   
g .   
go to the earliest dir. which is the deepest dir. of dir. stack   
g 0
go to the earliest dir. and reverse the dir. index order
g {nth}   
go to the nth index of dir. stack, exception is index 1 by g 1 below
g 1   
go to dir. pointed by the top of stack and remove the current directory, use g -otherwise to keep current dir at top of dir. stack    
g {directory_name}   
go to the "directory_name" dir. For numerical name, suffix it with / to prevail over existing same index number of dir. stack
g foo bar   
go to first of the listed dir. given, foo, while the rest of list is put in dir. stack    
g {0nth}...  
remove every given nth index of dir. stack   
g {0nth-}  
remove the nth index and every dir. greater than nth index of dir. stack   
g {0nth-Nth}  
remove every dir. index in the range nth to Nth index of dir. stack   
g 00   
clean up all dir. stack   


