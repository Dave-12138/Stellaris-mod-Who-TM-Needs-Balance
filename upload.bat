@REM 上传前修复：给中文本地化文件补 UTF-8 BOM（node 缺失等异常会中止上传）
node "%~dp0tools\fix_localisation_bom.mjs"
if errorlevel 1 (
	echo.
	echo [ABORT] localisation BOM fix failed - upload cancelled.
	pause
	exit /b 1
)
@REM 重建上传目录：只复制 mod 内容，不做全量复制
if exist ..\wtmnb_dist rd /s /q ..\wtmnb_dist
mkdir ..\wtmnb_dist
for %%d in (common events gfx interface localisation) do xcopy "%%d" "..\wtmnb_dist\%%d\" /i /s /y /q
copy /y descriptor.mod ..\wtmnb_dist\
copy /y thumbnail.png ..\wtmnb_dist\
@REM 源文件不随 mod 上传
del ..\wtmnb_dist\*.psd /s /q
@REM 上传mod
"%USERPROFILE%\Documents\agent-workspace\docker_steamcmd\upload.bat" ../wtmnb_dist ./wtmnb.vdf
@pause