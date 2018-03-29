@echo off
cd\
SET /P path= Insert folder path 
cd %path%
dir>contents.txt