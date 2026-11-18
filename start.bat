@echo off
title LLM Graph Builder - Launcher
color 0A

echo ============================================================
echo   LLM Graph Builder - Starting Backend + Frontend
echo ============================================================
echo.

:: Check Python venv exists
if not exist "%~dp0backend\venv\Scripts\python.exe" (
    echo [ERROR] Python venv not found at backend\venv
    echo Please run: cd backend ^&^& python -m venv venv ^&^& venv\Scripts\pip install -r requirements.txt
    pause
    exit /b 1
)

:: Check Node.js exists
where node >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Node.js is not installed or not in PATH
    pause
    exit /b 1
)

:: Kill any old processes on port 8000 and 5173
echo [*] Clearing old processes on port 8000 and 5173...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":8000.*LISTENING" 2^>nul') do (
    taskkill /PID %%p /F >nul 2>nul
)
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":5173.*LISTENING" 2^>nul') do (
    taskkill /PID %%p /F >nul 2>nul
)

echo.
echo [1/2] Starting Backend (FastAPI on port 8000)...
set "LLM_GRAPH_BUILDER_ENV_FILE=%~dp0.env"
echo     Loading configuration from %LLM_GRAPH_BUILDER_ENV_FILE%
start "LLM-GraphBuilder Backend" cmd /k "cd /d "%~dp0backend" && set "LLM_GRAPH_BUILDER_ENV_FILE=%~dp0.env" && echo Backend starting... && venv\Scripts\python.exe -m uvicorn score:app --host 0.0.0.0 --port 8000"

:: Wait a bit for backend to initialize
echo     Waiting 5 seconds for backend to boot...
timeout /t 5 /nobreak >nul

echo.
echo [2/2] Starting Frontend (Vite on port 5173)...
start "LLM-GraphBuilder Frontend" cmd /k "cd /d "%~dp0frontend" && echo Frontend starting... && npm run dev"

:: Wait and open browser
echo.
echo     Waiting 8 seconds for frontend to compile...
timeout /t 8 /nobreak >nul

echo.
echo ============================================================
echo   Opening browser at http://localhost:5173
echo ============================================================
start "" http://localhost:5173

echo.
echo [OK] Both servers are running.
echo      Backend  -^>  http://localhost:8000
echo      Frontend -^>  http://localhost:5173
echo.
echo Close the two terminal windows to stop the servers.
echo.
pause

