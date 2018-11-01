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
   * [FIFA 19 IDs](#fifa-19-ids)
   * [Permanent Stadium Change](#permanent-stadium-change)
   * [Changing Player Head Model](#changing-player-head-model)


## Update Progress
[Track update process on Trello](https://trello.com/b/oFNRNWWY/fifa-19-ct-update-progress)


## Release Schedule
When new version will be released? Answer is here: [Release Schedule](https://docs.google.com/spreadsheets/d/1EsYf4I4oDD6kw5jTGTFsv7rR1qL-Oausd1ZRbbSWm84/edit?usp=sharing)


## Video Tutorials

Video Tutorials UC Nerd -> [Watch on YouTube](http://bit.ly/CM-Cheat-Table-19)


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
__List of Head IDs can be found on [FIFA 19 IDs](#fifa-19-ids) list__

Now in __FIFA Database->Database Tables->Players table__ set:

1. Has High Quality Head to __1__
2. Head Class Code to __0__
3. Head Asset ID to __ID you want to use (i.e 1198)__
4. Head Variation to __0__

![](https://i.imgur.com/bMTnNbg.png)

__Effect__

![Before](https://i.imgur.com/t8pm49W.jpg)
![After](https://i.imgur.com/PFVjDjy.jpg)
