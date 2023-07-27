# smart-directories-navigation
Bash smart directories navigation
go or get into a directory keeping the previous directory saved, listed neatly right off o shell
It must be inside ~/.bashrc to get the executable g (stand for get into) function working directly, nicely, fast in shell terminal and no DIR shell variable else being used    
simply rename function name g with whatever you like; j (stand for jump into), b (stand for be in), etc    

g   
go to $HOME dir.   
g -   
go back to the last dir. you went from
g .   
go to the earliest dir. which is the deepest dir. of dir. stack   
g {nth}   
go to the nth index of dir. stack   
g {directory_name}   
go to the "directory_name" dir. For numeric name it must be suffixed with / to prevail over an existing same number of dir. stack index  
g foo bar   
go to first of the listed dir. given, foo, while the rest of list is put in dir. stack   
g {0nth}...  
remove the nth index of dir. stack   
g {0nth-}  
remove the nth index and every dir. greater than nth index of dir. stack   
g 0
if 
