@echo off
chcp 65001 >nul
echo ========================================
echo Сборка AdventurePuzzleGame.exe
echo ========================================
echo.

echo [1/3] Проверка зависимостей...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось установить зависимости
    pause
    exit /b 1
)

echo.
echo [2/3] Очистка предыдущих сборок...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist

echo.
echo [3/3] Сборка exe файла...
pyinstaller AdventurePuzzleGame.spec
if %errorlevel% neq 0 (
    echo ОШИБКА: Сборка не удалась
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✓ Сборка завершена успешно!
echo ========================================
echo.
echo Исполняемый файл: dist\AdventurePuzzleGame.exe
echo.
pause
