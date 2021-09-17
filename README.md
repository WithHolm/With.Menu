# With.Menu
A powershell module to show menus:  
![Menu](/docs/img/menu.jpg)




## Building a menu

The menu concists of the following items:

### Menu block

**Note:** for the menu to actually show you have to pipe menu to `|start-menu`. more on start-menu [here](#Start-menu)
``` Powershell
New-Menu -Title "A Menu" -Definition {}
```
This will generate a menu like this:
```
--------------------test-------------------
[R]efresh, [Q]uit: 
```



#### start-menu
A menu cmd