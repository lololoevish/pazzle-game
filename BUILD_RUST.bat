@echo off
chcp 65001 >nul
echo ========================================
echo   СБОРКА RUST-ВЕРСИИ ИГРЫ
echo ========================================
echo.

REM Проверка установки Rust
where cargo >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Rust не установлен!
    echo.
    echo Установите Rust с https://rustup.rs/
    echo Или выполните: winget install Rustlang.Rustup
    echo.
    pause
    exit /b 1
)

echo ✅ Rust установлен
cargo --version
echo.

echo Выберите режим сборки:
echo [1] Разработка (быстрая сборка)
echo [2] Релиз (оптимизированная)
echo.
set /p choice="Ваш выбор (1 или 2): "

if "%choice%"=="1" (
    echo.
    echo 🔨 Сборка в режиме разработки...
    cargo build
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ✅ Сборка завершена успешно!
        echo 📁 Файл: target\debug\game.exe
        echo.
        set /p run="Запустить игру? (y/n): "
        if /i "!run!"=="y" (
            target\debug\game.exe
        )
    ) else (
        echo.
        echo ❌ Ошибка сборки!
    )
) else if "%choice%"=="2" (
    echo.
    echo 🔨 Сборка релиза (это может занять несколько минут)...
    cargo build --release
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ✅ Сборка завершена успешно!
        echo 📁 Файл: target\release\game.exe
        echo.
        
        REM Копируем exe в корень
        copy target\release\game.exe AdventurePuzzleGame_Rust.exe
        echo.
        echo 📦 Скопировано в: AdventurePuzzleGame_Rust.exe
        echo.
        
        set /p run="Запустить игру? (y/n): "
        if /i "!run!"=="y" (
            AdventurePuzzleGame_Rust.exe
        )
    ) else (
        echo.
        echo ❌ Ошибка сборки!
    )
) else (
    echo.
    echo ❌ Неверный выбор!
)

echo.
echo ========================================
pause
