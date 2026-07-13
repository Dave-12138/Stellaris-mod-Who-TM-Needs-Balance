@REM 清理旧内容，复制，删除复制结果中不上传的部分
del ..\wtmnb_dist\* /s /q
xcopy * ..\wtmnb_dist\ /i /s /y
del ..\wtmnb_dist\*.vdf
del ..\wtmnb_dist\*.bat
del ..\wtmnb_dist\*.psd /s
del ..\wtmnb_dist\.*
del ..\wtmnb_dist\AGENTS.md
del ..\wtmnb_dist\opencode.json
@REM 上传mod
"%USERPROFILE%\Documents\agent-workspace\docker_steamcmd\upload.bat" ../wtmnb_dist ./wtmnb.vdf
@pause