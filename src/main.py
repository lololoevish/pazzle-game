import pygame
import sys
import os
import logging

# Настройка логирования
logging.basicConfig(filename='game.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger()

# Определяем базовую директорию
if getattr(sys, 'frozen', False):
    # Приложение запущено из exe
    base_path = os.path.dirname(sys.executable)
else:
    # Приложение запущено как скрипт
    base_path = os.path.abspath('.')

print("=== Игра запущена ===")
logger.info("Игра запущена")

# Добавляем путь к src
sys.path.insert(0, os.path.join(base_path, 'src'))

from scenes.menu import MenuScene
from scenes.gameplay import GameplayScene
from scenes.town import TownScene
from scenes.minigames import MiniGameScene
from utils.save_system import save_game, load_game, has_save

# Инициализация Pygame
pygame.init()

# Установка размеров экрана
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Приключенческая игра с головоломками")

# Цвета
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

# Часы для управления FPS
clock = pygame.time.Clock()
FPS = 60

# Состояния игры
STATE_MENU = "menu"
STATE_TOWN = "town"
STATE_PLAYING = "playing"
STATE_MINIGAME = "minigame"

# Попытка загрузить сохранение
saved_data = load_game()
if saved_data:
    game_progress, player_inventory = saved_data
    print("Сохранение загружено!")
    logger.info("Сохранение загружено")
else:
    # Прогресс игрока (какие уровни пройдены)
    game_progress = {
        1: {'completed': False, 'lever_pulled': False},
        2: {'completed': False, 'lever_pulled': False},
        3: {'completed': False, 'lever_pulled': False},
        4: {'completed': False, 'lever_pulled': False},
        5: {'completed': False, 'lever_pulled': False},
        6: {'completed': False, 'lever_pulled': False}
    }

    # Инвентарь игрока
    player_inventory = {
        'gold': 100,
        'items': [],
        'won_minigames': []
    }
    print("Новая игра начата")
    logger.info("Новая игра начата")

# Текущий уровень для игры
current_level = 1

# NPC для мини-игры
current_npc = None

# Начальное состояние - меню
current_state = STATE_MENU
current_scene = MenuScene(SCREEN_WIDTH, SCREEN_HEIGHT)

# Основной игровой цикл
running = True
while running:
    # Получение списка событий
    events = pygame.event.get()
    
    # Обработка событий
    for event in events:
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                if current_state == STATE_MINIGAME:
                    # Выход из мини-игры в город
                    current_state = STATE_TOWN
                    current_scene = TownScene(SCREEN_WIDTH, SCREEN_HEIGHT)
                    current_scene.progress = game_progress
                    current_scene.player_inventory = player_inventory
                elif current_state == STATE_PLAYING:
                    # Выход из игры в город
                    current_state = STATE_TOWN
                    current_scene = TownScene(SCREEN_WIDTH, SCREEN_HEIGHT)
                    current_scene.progress = game_progress
                    current_scene.player_inventory = player_inventory
                elif current_state == STATE_TOWN:
                    # Выход из города в меню
                    current_state = STATE_MENU
                    current_scene = MenuScene(SCREEN_WIDTH, SCREEN_HEIGHT)
                else:
                    running = False
    
    # Получение состояния клавиш
    keys_pressed = pygame.key.get_pressed()
    
    # Логика переключения состояний
    if current_state == STATE_MENU:
        # Обновление меню
        current_scene.handle_events(events)
        current_scene.update(keys_pressed)
        
        # Проверка завершения перехода (только один раз!)
        if current_scene.is_transition_complete():
            logger.info("Переход из меню завершен!")
            if current_scene.get_result() == 'play':
                logger.info("Переход в город...")
                # Переход в город
                current_state = STATE_TOWN
                current_scene = TownScene(SCREEN_WIDTH, SCREEN_HEIGHT)
                current_scene.progress = game_progress
                current_scene.player_inventory = player_inventory
                
    elif current_state == STATE_TOWN:
        # Обновление города
        current_scene.handle_events(events)
        current_scene.update(keys_pressed)
        
        # Проверка выбора уровня
        if current_scene.is_transition_complete():
            result = current_scene.get_result()
            if result == 'back':
                # Вернуться в меню
                current_state = STATE_MENU
                current_scene = MenuScene(SCREEN_WIDTH, SCREEN_HEIGHT)
            elif result and result.startswith('level'):
                # Переход к уровню
                level_num = int(result.replace('level', ''))
                current_level = level_num
                current_state = STATE_PLAYING
                current_scene = GameplayScene(SCREEN_WIDTH, SCREEN_HEIGHT, level_num)
                current_scene.progress = game_progress
            elif result and result.startswith('npc_'):
                # Переход к мини-игре NPC
                npc_index = int(result.replace('npc_', ''))
                current_npc = current_scene.npcs[npc_index]
                current_state = STATE_MINIGAME
                current_scene = MiniGameScene(SCREEN_WIDTH, SCREEN_HEIGHT, current_npc, player_inventory)
                
    elif current_state == STATE_MINIGAME:
        # Обновление мини-игры
        current_scene.handle_events(events)
        current_scene.update()
        
        # Проверка завершения мини-игры
        if current_scene.is_complete():
            result = current_scene.result
            if result == 'win':
                # Даём награду
                reward = current_scene.get_reward()
                if reward:
                    player_inventory['items'].append(reward)
                    player_inventory['gold'] += 50 if 'Золото' in reward else 0
                    player_inventory['won_minigames'].append(current_npc.name)
            # Возвращаемся в город
            current_state = STATE_TOWN
            current_scene = TownScene(SCREEN_WIDTH, SCREEN_HEIGHT)
            current_scene.progress = game_progress
            current_scene.player_inventory = player_inventory
                
    elif current_state == STATE_PLAYING:
        # Обновление игры
        current_scene.handle_events(events)
        current_scene.update(keys_pressed)
        
        # Проверка завершения уровня
        if current_scene.is_puzzle_solved():
            # Сохраняем прогресс
            level = current_scene.get_level()
            game_progress[level]['completed'] = True
            
            # Если рычаг был активирован
            if hasattr(current_scene, 'lever_pulled') and current_scene.lever_pulled:
                game_progress[level]['lever_pulled'] = True
    
    # Отрисовка
    if current_state == STATE_MENU:
        current_scene.draw(screen)
    elif current_state == STATE_TOWN:
        current_scene.draw(screen)
    elif current_state == STATE_MINIGAME:
        current_scene.draw(screen)
    elif current_state == STATE_PLAYING:
        current_scene.draw(screen)
        
        # Показываем сообщение о победе и ожидаем ввода
        if current_scene.is_puzzle_solved():
            # Дополнительная отрисовка - кнопка возврата
            font = pygame.font.SysFont('arial', 20)
            text = font.render("Нажмите ESC для возврата в город", True, (255, 255, 255))
            text_rect = text.get_rect(center=(SCREEN_WIDTH // 2, SCREEN_HEIGHT - 50))
            screen.blit(text, text_rect)

    # Обновление экрана
    pygame.display.flip()

    # Ограничение FPS
    clock.tick(FPS)

# Сохранение игры перед выходом
print("Сохранение прогресса...")
if save_game(game_progress, player_inventory):
    print("Игра сохранена успешно!")
    logger.info("Игра сохранена")
else:
    print("Ошибка сохранения игры")
    logger.error("Ошибка сохранения игры")

# Выход из игры
pygame.quit()
sys.exit()
