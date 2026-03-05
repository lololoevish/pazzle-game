@echo off
chcp 65001 >nul
title Отправка на GitHub

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ОТПРАВКА ПРОЕКТА НА GITHUB                            ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.

echo [1/6] Инициализация Git репозитория...
git init
if %errorlevel% neq 0 (
    echo ✗ Ошибка инициализации Git
    pause
    exit /b 1
)
echo ✓ Git репозиторий инициализирован

echo.
echo [2/6] Добавление удалённого репозитория...
git remote add origin https://github.com/lololoevish/pazzle-game.git
if %errorlevel% neq 0 (
    echo Репозиторий уже добавлен, обновляем...
    git remote set-url origin https://github.com/lololoevish/pazzle-game.git
)
echo ✓ Удалённый репозиторий настроен

echo.
echo [3/6] Добавление файлов...
git add .
if %errorlevel% neq 0 (
    echo ✗ Ошибка добавления файлов
    pause
    exit /b 1
)
echo ✓ Файлы добавлены

echo.
echo [4/6] Создание коммита...
git commit -m "Initial commit: Adventure Puzzle Game v1.1.0 with Visual Novel system"
if %errorlevel% neq 0 (
    echo ✗ Ошибка создания коммита
    pause
    exit /b 1
)
echo ✓ Коммит создан

echo.
echo [5/6] Установка основной ветки...
git branch -M main
echo ✓ Ветка main установлена

echo.
echo [6/6] Отправка на GitHub...
echo.
echo ВНИМАНИЕ: Сейчас потребуется авторизация GitHub!
echo.
git push -u origin main
if %errorlevel% neq 0 (
    echo.
    echo ✗ Ошибка отправки на GitHub
    echo.
    echo Возможные причины:
    echo 1. Не настроена авторизация Git
    echo 2. Нет прав доступа к репозиторию
    echo 3. Репозиторий не существует
    echo.
    echo Решение:
    echo 1. Настройте Git: git config --global user.name "Ваше имя"
    echo 2. Настройте Git: git config --global user.email "ваш@email.com"
    echo 3. Создайте репозиторий на GitHub: https://github.com/new
    echo.
    pause
    exit /b 1
)

echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║         ✓ ПРОЕКТ УСПЕШНО ОТПРАВЛЕН НА GITHUB!                ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Репозиторий: https://github.com/lololoevish/pazzle-game
echo.
pause
