# FIFA 19 - CM Cheat Table

This is a brief walk-through tutorial that illustrates how to use mine Cheat Table for FIFA 19. Before you start using it, I'd recommend you to make a __backup of your current career mode save__ and regular backups of your further progress. Trust me, you don't want to start a new career after 5 seasons because something will screw up. You need to know that this cheat table is designed for __manager career mode__. Scripts may or may not work in player career mode, especially if you are using player created by your own. I don't care about the journey mode, sorry. Also - as last year - cracked version is not supported and no, it doesn't mean that cheat table is not working with cracked version. Just if something is not working then it's because you are using cracked version. I hope it's clear now.
And the last thing but not least, __tick checkboxes only when you are activating scripts or opening header__. If you tick checkbox near attributes (like 'headid' in manager table) it will freeze the value and it will be applied to all other players/maangers/etc., which is probably not something that you want.

![](https://i.imgur.com/U5HpWO6.png)

# Become a Patron
[Become a Patron](https://www.patreon.com/xAranaktu)

# Table of Contents
   * [Update Progress](#update-progress)
   * [Release Schedule](#release-schedule)
   * [Video Tutorials](#video-tutorials)
   * [Getting Started](#getting-started)
   * [Frequently asked questions](#faq)
   * [Auto activating scripts](#auto-activating-scripts)
   * [FIFA 19 IDs](#fifa-19-ids)
   * [Permanent Stadium Change](#permanent-stadium-change)
   * [Changing Player Head Model](#changing-player-head-model)
   * [Changing Manager Head Model](#changing-manager-head-model)
   * [Removing injury from a player](#removing-injury-from-a-player)
   * [Contract Negotiation](#contract-negotiation)


## Release Schedule
When new version will be released? Answer is here: [Release Schedule](https://docs.google.com/spreadsheets/d/1EsYf4I4oDD6kw5jTGTFsv7rR1qL-Oausd1ZRbbSWm84/edit?usp=sharing)


## Video Tutorials

[Video Tutorials by UC Nerd](http://bit.ly/CM-Cheat-Table-19)

[Video Tutorials by FIFER](https://www.youtube.com/channel/UCLeUj4JLawrik11Ch9uoU_Q)


## Getting Started
* Download necessary software (if you don't have any of those):
  * [Newest version of cheat engine](https://www.cheatengine.org/downloads.php)
  * [Newest version of cheat table](https://mega.nz/#F!QIlRHIRD!NWSxbzysLhTzgvQeuFg0mg)
  * [Winrar](https://www.rarlab.com/download.htm) or [7zip](https://www.7-zip.org/)
  
* Install Cheat Engine
* Unzip Cheat Table with Winrar/7zip (doesn't matter where it's up to you.)
* Run FIFA and go to main menu (https://i.imgur.com/Jnq60Hf.jpg)
* Run Cheat Engine
* Allow Cheat Engine to execute Lua scripts (https://i.imgur.com/oOdOq7M.gifv)
* Open Cheat Table in Cheat Engine (https://i.imgur.com/pb0GIC1.gifv)
  * if you have latest Cheat table then just wait a few seconds until it will connect with the game and GUI will be shown (as on gif)
  * if you have cheat table version from v1.0.0 to v1.0.11 then press 'CTRL+P' and open 'FIFA19.exe' process (https://i.imgur.com/RjGdB8B.png)
* Activate your favourite scripts and load career save. :)

## F.A.Q

* __Can you make a cheat for FUT/Pro Clubs?__
  - No, I can't. Stop asking about that.


* __Can you add X/Y/Z ?__
  - Depends on what it is. If you have got a request write [here](https://github.com/xAranaktu/FIFA-19---Career-Mode-Cheat-Table/labels/enhancement) and maybe one day you will see it added to the table.


* __It's possible to make X/Y/Z?__
  - It's my favourite question. Guys, basically everything is possible, but not everything is worth doing. Do you want to play as Mario? Sure, it's possible, but I'll not spend 5 years on trying to import Mario model to the game just because one crazy guy wants to replace Messi with Italian plumber. If you have got a request write [here](https://github.com/xAranaktu/FIFA-19---Career-Mode-Cheat-Table/labels/enhancement) and maybe one day you will see it added to the table.


* __How can I edit age of a player?__
  - "Editing Player->Edit Player" and change "Birth Year". Editing birthdate under "player_data" is more complex.  It seems to be a number of days since 15.10.1582. You can use [online date calculators](https://www.timeanddate.com/date/durationresult.html?y1=1582&m1=10&d1=15&y2=2017&m2=9&d2=29&ti=on) for this. start date must be 1582-10-15, end date should be a date of birth of your player. if you want to have 17yo player just put there for example 2010-7-3. Result will be "156 221". So, if you set Messi birthdate to "156221" he should be 17yo.


* __How can I edit player traits?__
  - "FIFA Database->Database Tables->Players Table->Traits". As far as I know there is no limit, so your player can have all traits.


* __Why cracked version is not supported?__
  -  Cracked version is not supported because I've got original game copy bought on Origin. Most probably my game version and your game version will differ because I've got the newest patch, and you not. So, ingame functions are different, addresses are different, after a few patches we will probably play a different game.


* __After activating function nothing happens, what's wrong?__
  - Try to restart the game and cheat engine, or maybe even your PC, also make sure you have started FIFA before cheat engine and you are attached to the game process. If it's not helping try to use older versions of cheat table.


* __My game is crashing.__
  - It's a right time to use your save backup. :)

* __How to keep options in cheat table activated permanently?__
  - [Auto activating scripts](#auto-activating-scripts)

* __What's "Transfer.ini & Transfers.ini"?__
  - This script is allowing to edit some settings from these .ini files. Generally, it can be used to make transfer window more active. This script is using default settings, you need to edit it to see any difference in the game. Right-click -> Change script -> Edit what you want to edit (Just change value after "#".) -> Ok -> Activate script -> Load your career save.


* __How to use "Send scout to any country"?__
  - Choose scout -> Set up a Scouting Network -> In CE activate "Send scout to any country" and change "Nationality ID" -> Back to FIFA window and send scout on a mission (doesn't matter which country you pick). Nationality ID's list is available [here](https://docs.google.com/spreadsheets/d/1eYx5j7FZwlaPKymv3_G-ezZKtfWmQ6hwjXukAfqYoto/edit?usp=sharing)

    
* __How to replace generic manager with real one?__
  - [Changing Manager Head Model](#changing-manager-head-model)
  
* __How can I make my player to run exactly the same as 'Ronaldo'?__
  - I've written short guide how to do that on the soccergaming forum. -> [How to run like Ronaldo](http://soccergaming.com/index.php?threads/fifa-18-career-mode-cheat-table.6459576/page-17#post-6488623)
  
* __How to edit data in career_managerpref/career_managerinfo/career_users/career_calendar Table?__
    
    Same as in FIFA 18. :)

  - In Cheat Engine Settings change debugger method to "VEH Debugger" (https://i.imgur.com/z4Q94Hn.png)
  - Activate "Database Tables" script
  - Load your career save to initialize pointers.
  - Exit career
  - In Cheat Engine go to "Memory Viewer" -> Press "CTRL + G" -> Go to address "INJECT_DatabaseRead" -> Follow jmp (https://i.imgur.com/gPHckIj.png) -> Scroll down until you will see "mov [usersDataPtr],r8" instruction -> Set breakpoint there (https://i.imgur.com/QZCd8ZO.png)
  - Load your career save, when game will freeze do the changes in database tables.
  - After you edit what you want go back to memory Viewer and delete breakpoint (https://i.imgur.com/o7YrN2V.png)
  - press 'F9' to unfreeze the game (https://i.imgur.com/jMBAnGd.png)

* __Can I buy player who “recently joined a club”?__
  - Yes, you need to edit "playerjointeamdate". Value "158229" should be fine. You will find it in "FIFA Database->Database Tables->Players table->Player Info".
  
* __How can I change player name?__
  
  - In "Editing Player" activate "Edit Player" script.
  - In game go to "Edit Player" 
  
  ![](https://i.imgur.com/lzIThn0.png)
  
  - If you want to edit "Known As" name you need to initialize pointers on a player that has got that name. In example. Arthur from FC Barcelona or Isco from Real. To initialize pointers you need to enter into editing Arthur and then just "Done"->"Apply & Exit"
  
  ![](https://i.imgur.com/l5xy7Tv.png)
  
  - Now you can see in Cheat Table that it's ready for editing player names
  
  ![](https://i.imgur.com/gOa3Nvu.png)
  
  - Find on Edit Player list player that you want to edit and click on him
  
  ![](https://i.imgur.com/FI0o5xo.png)
  
  - You can edit player name now including "Known As" name. Remember to click on "Apply & Exit" to save the changes.
  
  ![](https://i.imgur.com/FaeU9kX.png)
  

## Auto activating scripts
Because cheat table contains a lot of scripts, you may want to let cheat engine to activate it for you.
* For latest cheat table version
  * Go to settings (https://i.imgur.com/y7AnsA3.png)
  * Select scripts which will be activated and save (https://i.imgur.com/P27Gji5.gifv)
  * Next time when you run Cheat Table selected scripts will be automatically activate by cheat engine
  
* For cheat table version from 1.0.0 to 1.0.11
  * You can use lua to make your life easier. Press "CTRL+ALT+L" in cheat engine to open Cheat Table Lua script. [here](http://fearlessrevolution.com/viewtopic.php?f=4&t=4976&p=21649#p21608) you can read how to use autoattach.lua script.


## FIFA 19 IDs

List of FIFA 19 IDs is available here -> [Google Drive](https://docs.google.com/spreadsheets/d/1eYx5j7FZwlaPKymv3_G-ezZKtfWmQ6hwjXukAfqYoto/edit?usp=sharing) 


## Permanent Stadium Change
How to change your home stadium permanently.
On example I'm changing AC Milan Home Stadium from 'San Siro' (ID: 5) to 'Old Trafford' (ID: 1)
1. In cheat table activate "career_managerpref Table" and "teamstadiumlinks Table"
2. You need to have an __upcoming match on your home stadium__

![](https://i.imgur.com/GdlyMZT.png) 

3. Press 'Play Match' and go to 'Match Preview' screen

![](https://i.imgur.com/VAmtWVS.jpg)

4. Back to cheat table and edit __'stadiumid'__ in __career_managerpref Table__ and __'stadiumid'__ in __teamstadiumlinks Table__. Dunno if it's necessary, but for safety, I also recommend you to change 'stadiumname' in teamstadiumlinks Table.

![](https://i.imgur.com/0GSyosR.png)

5. Now just play this match (you will play it on old stadium) or simulate it and the next home match will be played on the new stadium. Saving and reloading career save at this point may also work, so playing match on old stadium will be not needed.

![](https://i.imgur.com/nmVhcn8.jpg)

## Changing Player Head Model
__List of Head IDs can be found on [FIFA 19 IDs](https://docs.google.com/spreadsheets/d/1eYx5j7FZwlaPKymv3_G-ezZKtfWmQ6hwjXukAfqYoto/edit?usp=sharing) list__

Now in __FIFA Database->Database Tables->Players table__ set:

1. Has High Quality Head to __1__
2. Head Class Code to __0__
3. Head Asset ID to __ID you want to use (i.e 1198)__
4. Head Variation to __0__

![](https://i.imgur.com/bMTnNbg.png)

__Effect__

![Before](https://i.imgur.com/t8pm49W.jpg)
![After](https://i.imgur.com/PFVjDjy.jpg)

## Changing Manager Head Model
__List of Head IDs can be found on [FIFA 19 IDs](https://docs.google.com/spreadsheets/d/1eYx5j7FZwlaPKymv3_G-ezZKtfWmQ6hwjXukAfqYoto/edit?usp=sharing) list__

Method 1 (my method):
1. Activate "Manager Table"
2. Activate "Filter"
3. In "Team ID Filter" put ID of your team. From sofifa for example or from [FIFA 19 IDs](https://docs.google.com/spreadsheets/d/1eYx5j7FZwlaPKymv3_G-ezZKtfWmQ6hwjXukAfqYoto/edit?usp=sharing).
4. Activate "Team ID Filter"
5. Go to "News" in-game.
6. If teamid in manager table will be your teamid - 1 (as on screen below) then you can make your changes.
![](https://i.imgur.com/hxxc0EW.png)
7. Put any Head Model id from [FIFA 19 IDs](https://docs.google.com/spreadsheets/d/1eYx5j7FZwlaPKymv3_G-ezZKtfWmQ6hwjXukAfqYoto/edit?usp=sharing) in 'headid' field to change head model of your manager.

__If condition from point 6. is not met you need to find a news which will query manager database. Just click randomly on different tabs and news until you will have same situation as on screen above.__

[Method 2 (Dunno who is the author of this)](https://docs.google.com/document/d/e/2PACX-1vTwIl5tMySFCSqymJsBXtAOSKFNmyv7kUfembGp7EFbXFJzcjmnAGh9N8LHKU5GBl8rfSJU2cckiCyA/pub)

[Method 3 (RDBM 19)](https://docs.google.com/document/d/1LUM2z1cO_RcS2k91Jpea04lhQW33cjOO1-2BXeE-CSM/edit?usp=sharing)

## Removing injury from a player

- Activate "Players Injuries" script
- Go to "Transfers" -> "Search Players" in-game

![](https://i.imgur.com/NsH5CM1.jpg)

- Find injured player

![](https://i.imgur.com/Hx8JCuv.png)

- Click on him

![](https://i.imgur.com/iKa2bbS.png)

- Now in Cheat Engine change following values: playerid to '4294967295', Recovery Date to '20080101' and set the rest to '0'

![](https://i.imgur.com/IhY8W8c.png)

- Done. Injury has been removed

![](https://i.imgur.com/c6w3wvm.png)


## Contract Negotiation
Any terms you set here will be accepted by the player during contract negotiations.

[Contract Negotiation - Video Tutorial by Und3rcov3r Nerd
](https://youtu.be/Y9t2QilaC8M?t=65)

* **Contract Negotiation**
  - Wage - Self-explanatory. It's 500 by default. 
  - Contract Length - Self-explanatory. It's 72 by default (6 years). 
  - Release Clause - Self-explanatory. It's 0 by default, so a player will not have a release clause. 
  - Squad Role - It's 5 by default. 5 = Prospect, 4 = Sporadic, 3 = Rotation, 2 = Important, 1 = Crucial
  - Signing Bonus - It's 0 by default.
  - Bonus Type - It's 0 by default. 0 = Appearances, 1 = Clean Sheets, 2 = Goals scored
  - Bonus Type - Count - It's 50 by default. 
  - Bonus Type - Sum - It's 5 by default. You will pay 5$ after player will reach bonus type count.
