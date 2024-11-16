@echo off
set LUA_PATH=;;..\?.lua
set LUA_CPATH=;;..\?.dll
set LUAJIT_BIN_PATH=
PATH=%LUAJIT_BIN_PATH%;%path%
luajit test.lua
