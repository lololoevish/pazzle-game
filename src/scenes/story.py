"""
Сюжетные сцены с элементами визуальной новеллы
"""
import pygame
import sys
sys.path.insert(0, '..')
from utils.dialogue_system import VisualNovelScene


class StoryScene:
    """Сюжетная сцена с диалогами"""
    
    def __init__(self, screen_width, screen_height, story_id='intro'):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.story_id = story_id
        
        # Визуальная новелла
        self.vn_scene = VisualNovelScene(screen_width, screen_height)
        
        # Загрузка сюжета
        self.load_story(story_id)
        
        # Состояние
        self.is_finished = False
        
    def load_story(self, story_id):
        """Загрузка сюжетной сцены"""
        
        if story_id == 'intro':
            # Вступительная сцена
            self.vn_scene.add_character("Мудрец", position='left', color=(80, 60, 120))
            self.vn_scene.add_character("Герой", position='right', color=(120, 80, 60))
            
            self.vn_scene.show_character("Мудрец")
            self.vn_scene.show_character("Герой")
            
            dialogues = [
                ("Мудрец", "Добро пожаловать, путник! Ты пришёл в наш город в трудное время."),
                ("Герой", "Что случилось? Почему город выглядит таким мрачным?"),
                ("Мудрец", "Древнее зло пробудилось в подземельях. Только тот, кто решит все головоломки, сможет его остановить."),
                ("Герой", "Я готов принять этот вызов! Где находятся эти головоломки?"),
                ("Мудрец", "В городе есть шесть врат. За каждыми - испытание. Пройди их все, и ты спасёшь нас!"),
                ("Герой", "Я не подведу! Начинаю прямо сейчас!"),
            ]
            
            self.vn_scene.start_dialogue(dialogues)
            
        elif story_id == 'level1_complete':
            # После первого уровня
            self.vn_scene.add_character("Мудрец", position='center', color=(80, 60, 120))
            self.vn_scene.show_character("Мудрец")
            
            dialogues = [
                ("Мудрец", "Превосходно! Ты прошёл первое испытание!"),
                ("Мудрец", "Но впереди ещё много трудностей. Продолжай свой путь!"),
            ]
            
            self.vn_scene.start_dialogue(dialogues)
            
        elif story_id == 'level3_complete':
            # После третьего уровня
            self.vn_scene.add_character("Торговец", position='left', color=(100, 120, 60))
            self.vn_scene.add_character("Герой", position='right', color=(120, 80, 60))
            
            self.vn_scene.show_character("Торговец")
            self.vn_scene.show_character("Герой")
            
            dialogues = [
                ("Торговец", "Ого! Ты уже прошёл половину испытаний!"),
                ("Герой", "Да, но с каждым разом становится всё сложнее..."),
                ("Торговец", "Не сдавайся! У меня есть кое-что, что может тебе помочь."),
                ("Торговец", "Возьми этот амулет. Он принесёт тебе удачу!"),
                ("Герой", "Спасибо! Я обязательно справлюсь!"),
            ]
            
            self.vn_scene.start_dialogue(dialogues)
            
        elif story_id == 'finale':
            # Финальная сцена
            self.vn_scene.add_character("Мудрец", position='left', color=(80, 60, 120))
            self.vn_scene.add_character("Герой", position='right', color=(120, 80, 60))
            
            self.vn_scene.show_character("Мудрец")
            self.vn_scene.show_character("Герой")
            
            dialogues = [
                ("Мудрец", "Невероятно! Ты прошёл все испытания!"),
                ("Герой", "Это было нелегко, но я справился!"),
                ("Мудрец", "Древнее зло побеждено! Город спасён благодаря тебе!"),
                ("Герой", "Я рад, что смог помочь. Что теперь?"),
                ("Мудрец", "Теперь ты - легенда! Твоё имя навсегда останется в истории нашего города!"),
                ("Герой", "Спасибо за доверие. Это было великое приключение!"),
                ("", "=== ПОЗДРАВЛЯЕМ! ВЫ ПРОШЛИ ИГРУ! ==="),
            ]
            
            self.vn_scene.start_dialogue(dialogues)
            
    def handle_events(self, events):
        """Обработка событий"""
        self.vn_scene.handle_events(events)
        
        # Проверка завершения
        if self.vn_scene.is_complete():
            self.is_finished = True
            
    def update(self, keys_pressed):
        """Обновление"""
        self.vn_scene.update()
        
    def draw(self, screen):
        """Отрисовка"""
        self.vn_scene.draw(screen)
        
    def is_complete(self):
        """Проверка завершения сцены"""
        return self.is_finished


# Пример использования в городе
class TownWithStory:
    """Расширение города с сюжетными сценами"""
    
    def __init__(self):
        self.story_triggers = {
            'first_visit': False,
            'level1_done': False,
            'level3_done': False,
            'all_done': False,
        }
        
    def should_show_story(self, progress):
        """Проверка, нужно ли показать сюжетную сцену"""
        # Первое посещение
        if not self.story_triggers['first_visit']:
            self.story_triggers['first_visit'] = True
            return 'intro'
            
        # После первого уровня
        if progress.get(1, {}).get('completed') and not self.story_triggers['level1_done']:
            self.story_triggers['level1_done'] = True
            return 'level1_complete'
            
        # После третьего уровня
        if progress.get(3, {}).get('completed') and not self.story_triggers['level3_done']:
            self.story_triggers['level3_done'] = True
            return 'level3_complete'
            
        # Все уровни пройдены
        all_complete = all(progress.get(i, {}).get('completed', False) for i in range(1, 7))
        if all_complete and not self.story_triggers['all_done']:
            self.story_triggers['all_done'] = True
            return 'finale'
            
        return None
