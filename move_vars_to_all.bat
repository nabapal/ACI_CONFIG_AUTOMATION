@echo off
REM Move all variable files from group_vars\vars\ to group_vars\all\
if not exist group_vars\all mkdir group_vars\all
move group_vars\vars\*.yaml group_vars\all\
echo All variable files moved to group_vars\all\
