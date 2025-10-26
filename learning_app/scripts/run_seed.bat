@echo off
echo Starting Firebase data seeding using REST API...
echo.

cd /d "%~dp0"

echo Checking Python installation...
python --version
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7 or higher from https://www.python.org/
    pause
    exit /b 1
)

echo.
echo Installing required packages...
pip install -r requirements.txt

echo.
echo Running REST API data seeding script...
python add_data_rest.py

echo.
echo Seeding completed!
pause
