@echo off
ECHO Creating Cheat Table folder in Documents\FIFA 19
SET ct_path=%HOMEDRIVE%\Users\%USERNAME%\Documents\FIFA 19\Cheat Table\
SET cache_path=%ct_path%cache\
md "%cache_path%crest"
md "%cache_path%heads"
md "%cache_path%youthheads"
md "%ct_path%data"
copy tmp\crest_notfound.png "%cache_path%crest\notfound.png" 
copy tmp\heads_notfound.png "%cache_path%heads\notfound.png"