@echo off
setlocal EnableDelayedExpansion
if exist res rd /q /s res
md res
if not exist release md release

set scriptdir=.\
set outputpath=release\latest.spk

echo 拷贝脚本文件
for %%i in (%scriptdir%\*.lua) do call :make %%i res

echo 拷贝数据文件
for %%i in (%scriptdir%\data\*) do call :make %%i res\data

echo 拷贝图片资源
for %%i in (%scriptdir%\pic\*) do call :make %%i res\pic

echo 拷贝其它文件
call :make %scriptdir%\icon.png res
call :make %scriptdir%\UserVarDef.xml res
call :make %scriptdir%\manifest.xml res

echo 写入编译时间
for /f "tokens=1 delims= " %%i in ("%date%") do set /p=%%i<nul>res\buildinfo.txt

echo 生成资源文件
start /B /WAIT WinRAR a -m5 -r0 -ep1 res.zip res\*
if exist %outputpath% del /q %outputpath%
move /y res.zip %outputpath%>nul
rd /q /s res
echo 资源打包完成，保存路径：%outputpath%
pause>nul
goto :eof

:make
if exist %1 (
  echo  *%~nx1
  if not exist %2 md %2
  copy /y %1 %2>nul
)
goto :eof
