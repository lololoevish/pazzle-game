"""
Система сохранений для игры
Сохраняет прогресс игрока в JSON файл
"""
import json
import os
import sys

def get_save_path():
    """Получить путь к файлу сохранения"""
    if getattr(sys, 'frozen', False):
        # Запущено из exe - сохраняем рядом с exe
        base_path = os.path.dirname(sys.executable)
    else:
        # Запущено как скрипт - сохраняем в корне проекта
        base_path = os.path.abspath('.')
    
    return os.path.join(base_path, 'savegame.json')

def save_game(game_progress, player_inventory):
    """
    Сохранить игру
    
    Args:
        game_progress: Словарь с прогрессом уровней
        player_inventory: Словарь с инвентарем игрока
    """
    save_data = {
        'progress': game_progress,
        'inventory': player_inventory
    }
    
    try:
        save_path = get_save_path()
        with open(save_path, 'w', encoding='utf-8') as f:
            json.dump(save_data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"Ошибка сохранения: {e}")
        return False

def load_game():
    """
    Загрузить игру
    
    Returns:
        Кортеж (game_progress, player_inventory) или None если сохранения нет
    """
    try:
        save_path = get_save_path()
        if not os.path.exists(save_path):
            return None
        
        with open(save_path, 'r', encoding='utf-8') as f:
            save_data = json.load(f)
        
        # Конвертируем ключи обратно в int для прогресса
        progress = {int(k): v for k, v in save_data['progress'].items()}
        inventory = save_data['inventory']
        
        return progress, inventory
    except Exception as e:
        print(f"Ошибка загрузки: {e}")
        return None

def has_save():
    """Проверить, есть ли файл сохранения"""
    save_path = get_save_path()
    return os.path.exists(save_path)

def delete_save():
    """Удалить файл сохранения"""
    try:
        save_path = get_save_path()
        if os.path.exists(save_path):
            os.remove(save_path)
        return True
    except Exception as e:
        print(f"Ошибка удаления сохранения: {e}")
        return False
