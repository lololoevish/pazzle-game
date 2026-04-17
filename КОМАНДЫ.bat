@echo off
chcp 65001 >nul
title Adventure Puzzle Game - Меню команд

:menu
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ADVENTURE PUZZLE GAME - МЕНЮ КОМАНД                   ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo  [1] 🚀 Собрать игру в EXE
echo  [2] 🎮 Запустить из исходников (для разработки)
echo  [3] 🧹 Очистить временные файлы
echo  [4] 📦 Открыть папку с EXE
echo  [5] 📝 Показать версию
echo  [6] 🔧 Установить зависимости
echo  [7] ❌ Выход
echo.
echo ═══════════════════════════════════════════════════════════════
echo.

choice /C 1234567 /N /M "Выберите действие (1-7): "

if errorlevel 7 goto exit
if errorlevel 6 goto install
if errorlevel 5 goto version
if errorlevel 4 goto opendist
if errorlevel 3 goto clean
if errorlevel 2 goto run
if errorlevel 1 goto build

:build
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         СБОРКА ИГРЫ                                           ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
call ЗАПУСК_СБОРКИ.bat
goto menu

:run
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ЗАПУСК ИЗ ИСХОДНИКОВ                                  ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Запуск игры...
python src/main.py
echo.
pause
goto menu

:clean
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ                              ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
call очистка.bat
goto menu

:opendist
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ОТКРЫТИЕ ПАПКИ DIST                                   ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
if exist dist (
    explorer dist
    echo ✓ Папка dist открыта
) else (
    echo ✗ Папка dist не найдена
    echo   Сначала соберите игру (пункт 1)
)
echo.
pause
goto menu

:version
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ИНФОРМАЦИЯ О ВЕРСИИ                                   ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
type VERSION.txt
echo.
pause
goto menu

:install
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         УСТАНОВКА ЗАВИСИМОСТЕЙ                                ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Установка pygame и pyinstaller...
pip install -r requirements.txt
echo.
if %errorlevel% equ 0 (
    echo ✓ Зависимости установлены успешно!
) else (
    echo ✗ Ошибка установки зависимостей
)
echo.
pause
goto menu

:exit
cls
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ВЫХОД                                                 ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Спасибо за использование Adventure Puzzle Game!
echo.
timeout /t 2 >nul
exit
