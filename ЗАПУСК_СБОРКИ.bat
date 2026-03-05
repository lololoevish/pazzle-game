@echo off
chcp 65001 >nul
title Сборка игры AdventurePuzzleGame

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     СБОРКА ADVENTURE PUZZLE GAME В EXE                     ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

call build_exe.bat

if exist "dist\AdventurePuzzleGame.exe" (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║     ✓ СБОРКА ЗАВЕРШЕНА УСПЕШНО!                           ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Файл находится: dist\AdventurePuzzleGame.exe
    echo.
    echo Хотите запустить игру? (Y/N)
    choice /C YN /N /M "Ваш выбор: "
    if errorlevel 2 goto end
    if errorlevel 1 goto run
) else (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║     ✗ ОШИБКА СБОРКИ                                       ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    pause
    exit /b 1
)

:run
echo.
echo Запуск игры...
cd dist
start AdventurePuzzleGame.exe
cd ..

:end
echo.
echo Готово!
pause
