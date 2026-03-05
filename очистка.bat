@echo off
chcp 65001 >nul
echo ========================================
echo Очистка временных файлов
echo ========================================
echo.

echo Удаление папок build и dist...
if exist build (
    rmdir /s /q build
    echo ✓ Папка build удалена
) else (
    echo - Папка build не найдена
)

if exist dist (
    rmdir /s /q dist
    echo ✓ Папка dist удалена
) else (
    echo - Папка dist не найдена
)

echo.
echo Удаление __pycache__...
for /d /r . %%d in (__pycache__) do @if exist "%%d" (
    rmdir /s /q "%%d"
    echo ✓ Удалено: %%d
)

echo.
echo Удаление .pyc файлов...
del /s /q *.pyc 2>nul

echo.
echo Удаление логов...
if exist src\game.log (
    del src\game.log
    echo ✓ Лог-файл удалён
)

if exist game.log (
    del game.log
    echo ✓ Лог-файл удалён
)

echo.
echo ========================================
echo ✓ Очистка завершена!
echo ========================================
pause
