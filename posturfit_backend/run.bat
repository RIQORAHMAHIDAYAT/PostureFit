@echo off
echo.
echo  ====================================================
echo   PostureFit Backend Server
echo   Listening on: http://0.0.0.0:8000
echo   Docs:         http://127.0.0.1:8000/docs
echo  ====================================================
echo.
cd /d "%~dp0"
call venv\Scripts\activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause