"""
Система диалогов для визуальной новеллы
"""
import pygame


class DialogueBox:
    """Диалоговое окно для отображения текста"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        
        # Размеры и позиция диалогового окна
        self.box_height = 150
        self.box_y = screen_height - self.box_height - 20
        self.box_rect = pygame.Rect(20, self.box_y, screen_width - 40, self.box_height)
        
        # Текущий диалог
        self.current_text = ""
        self.current_speaker = ""
        self.displayed_text = ""
        self.text_index = 0
        self.text_speed = 2  # Символов за кадр
        
        # Состояние
        self.is_active = False
        self.is_complete = False
        self.waiting_for_input = False
        
        # Шрифты
        self.font_speaker = pygame.font.SysFont('arial', 24, bold=True)
        self.font_text = pygame.font.SysFont('arial', 20)
        
        # Цвета
        self.bg_color = (20, 20, 40, 220)
        self.border_color = (100, 100, 150)
        self.text_color = (255, 255, 255)
        self.speaker_color = (255, 215, 0)
        
        # Индикатор продолжения
        self.continue_blink = 0
        
    def start_dialogue(self, speaker, text):
        """Начать новый диалог"""
        self.current_speaker = speaker
        self.current_text = text
        self.displayed_text = ""
        self.text_index = 0
        self.is_active = True
        self.is_complete = False
        self.waiting_for_input = False
        
    def update(self):
        """Обновление анимации текста"""
        if not self.is_active:
            return
            
        # Анимация появления текста
        if self.text_index < len(self.current_text):
            self.text_index += self.text_speed
            if self.text_index > len(self.current_text):
                self.text_index = len(self.current_text)
            self.displayed_text = self.current_text[:self.text_index]
        else:
            self.waiting_for_input = True
            
        # Мигание индикатора
        self.continue_blink += 1
        if self.continue_blink > 60:
            self.continue_blink = 0
            
    def skip_animation(self):
        """Пропустить анимацию текста"""
        if self.is_active and not self.waiting_for_input:
            self.text_index = len(self.current_text)
            self.displayed_text = self.current_text
            self.waiting_for_input = True
            
    def next(self):
        """Перейти к следующему диалогу"""
        if self.waiting_for_input:
            self.is_complete = True
            self.is_active = False
            return True
        return False
        
    def draw(self, screen):
        """Отрисовка диалогового окна"""
        if not self.is_active:
            return
            
        # Фон диалогового окна
        box_surface = pygame.Surface((self.box_rect.width, self.box_rect.height), pygame.SRCALPHA)
        pygame.draw.rect(box_surface, self.bg_color, (0, 0, self.box_rect.width, self.box_rect.height), border_radius=10)
        pygame.draw.rect(box_surface, self.border_color, (0, 0, self.box_rect.width, self.box_rect.height), 3, border_radius=10)
        screen.blit(box_surface, self.box_rect.topleft)
        
        # Имя говорящего
        if self.current_speaker:
            speaker_surf = self.font_speaker.render(self.current_speaker, True, self.speaker_color)
            screen.blit(speaker_surf, (self.box_rect.x + 20, self.box_rect.y + 15))
            
        # Текст диалога (с переносом строк)
        text_y = self.box_rect.y + 50
        words = self.displayed_text.split(' ')
        lines = []
        current_line = ""
        
        for word in words:
            test_line = current_line + word + " "
            test_surf = self.font_text.render(test_line, True, self.text_color)
            if test_surf.get_width() < self.box_rect.width - 40:
                current_line = test_line
            else:
                if current_line:
                    lines.append(current_line)
                current_line = word + " "
        if current_line:
            lines.append(current_line)
            
        for line in lines[:3]:  # Максимум 3 строки
            text_surf = self.font_text.render(line, True, self.text_color)
            screen.blit(text_surf, (self.box_rect.x + 20, text_y))
            text_y += 30
            
        # Индикатор продолжения
        if self.waiting_for_input and self.continue_blink < 30:
            continue_text = "▼ Нажмите Enter или Пробел"
            continue_surf = self.font_text.render(continue_text, True, (200, 200, 200))
            screen.blit(continue_surf, (self.box_rect.x + self.box_rect.width - continue_surf.get_width() - 20, 
                                       self.box_rect.y + self.box_rect.height - 35))


class DialogueSequence:
    """Последовательность диалогов"""
    
    def __init__(self, screen_width, screen_height):
        self.dialogue_box = DialogueBox(screen_width, screen_height)
        self.dialogues = []
        self.current_index = 0
        self.is_active = False
        self.is_complete = False
        
    def start_sequence(self, dialogues):
        """
        Начать последовательность диалогов
        dialogues: список кортежей (speaker, text)
        """
        self.dialogues = dialogues
        self.current_index = 0
        self.is_active = True
        self.is_complete = False
        
        if self.dialogues:
            speaker, text = self.dialogues[0]
            self.dialogue_box.start_dialogue(speaker, text)
            
    def handle_input(self, event):
        """Обработка ввода"""
        if not self.is_active:
            return
            
        if event.type == pygame.KEYDOWN:
            if event.key in (pygame.K_RETURN, pygame.K_SPACE):
                if self.dialogue_box.waiting_for_input:
                    # Переход к следующему диалогу
                    self.current_index += 1
                    if self.current_index < len(self.dialogues):
                        speaker, text = self.dialogues[self.current_index]
                        self.dialogue_box.start_dialogue(speaker, text)
                    else:
                        # Последовательность завершена
                        self.is_active = False
                        self.is_complete = True
                else:
                    # Пропустить анимацию
                    self.dialogue_box.skip_animation()
                    
    def update(self):
        """Обновление"""
        if self.is_active:
            self.dialogue_box.update()
            
    def draw(self, screen):
        """Отрисовка"""
        if self.is_active:
            self.dialogue_box.draw(screen)
            
    def reset(self):
        """Сброс последовательности"""
        self.current_index = 0
        self.is_active = False
        self.is_complete = False


class CharacterPortrait:
    """Портрет персонажа для визуальной новеллы"""
    
    def __init__(self, x, y, width, height, name, color):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.name = name
        self.color = color
        self.visible = False
        self.alpha = 0
        self.target_alpha = 0
        
    def show(self):
        """Показать портрет"""
        self.visible = True
        self.target_alpha = 255
        
    def hide(self):
        """Скрыть портрет"""
        self.target_alpha = 0
        
    def update(self):
        """Обновление анимации появления/исчезновения"""
        if self.alpha < self.target_alpha:
            self.alpha += 15
            if self.alpha > self.target_alpha:
                self.alpha = self.target_alpha
        elif self.alpha > self.target_alpha:
            self.alpha -= 15
            if self.alpha < self.target_alpha:
                self.alpha = self.target_alpha
                
        if self.alpha == 0:
            self.visible = False
            
    def draw(self, screen):
        """Отрисовка портрета"""
        if not self.visible and self.alpha == 0:
            return
            
        # Создаём простой портрет (цветной прямоугольник с именем)
        portrait_surf = pygame.Surface((self.width, self.height), pygame.SRCALPHA)
        
        # Фон портрета
        color_with_alpha = (*self.color, self.alpha)
        pygame.draw.rect(portrait_surf, color_with_alpha, (0, 0, self.width, self.height), border_radius=10)
        pygame.draw.rect(portrait_surf, (255, 255, 255, self.alpha), (0, 0, self.width, self.height), 3, border_radius=10)
        
        # Имя персонажа
        font = pygame.font.SysFont('arial', 20, bold=True)
        name_surf = font.render(self.name, True, (255, 255, 255, self.alpha))
        name_rect = name_surf.get_rect(center=(self.width // 2, self.height - 30))
        portrait_surf.blit(name_surf, name_rect)
        
        screen.blit(portrait_surf, (self.x, self.y))


class VisualNovelScene:
    """Сцена визуальной новеллы с портретами и диалогами"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.dialogue_sequence = DialogueSequence(screen_width, screen_height)
        
        # Портреты персонажей
        self.portraits = {}
        
        # Фон
        self.background_color = (30, 30, 50)
        
    def add_character(self, name, position='left', color=(100, 100, 150)):
        """
        Добавить персонажа
        position: 'left', 'center', 'right'
        """
        portrait_width = 150
        portrait_height = 200
        
        if position == 'left':
            x = 50
        elif position == 'center':
            x = (self.screen_width - portrait_width) // 2
        else:  # right
            x = self.screen_width - portrait_width - 50
            
        y = self.screen_height - 350
        
        portrait = CharacterPortrait(x, y, portrait_width, portrait_height, name, color)
        self.portraits[name] = portrait
        
    def show_character(self, name):
        """Показать персонажа"""
        if name in self.portraits:
            self.portraits[name].show()
            
    def hide_character(self, name):
        """Скрыть персонажа"""
        if name in self.portraits:
            self.portraits[name].hide()
            
    def start_dialogue(self, dialogues):
        """Начать диалог"""
        self.dialogue_sequence.start_sequence(dialogues)
        
    def handle_events(self, events):
        """Обработка событий"""
        for event in events:
            self.dialogue_sequence.handle_input(event)
            
    def update(self):
        """Обновление"""
        self.dialogue_sequence.update()
        for portrait in self.portraits.values():
            portrait.update()
            
    def draw(self, screen):
        """Отрисовка"""
        # Фон
        screen.fill(self.background_color)
        
        # Портреты
        for portrait in self.portraits.values():
            portrait.draw(screen)
            
        # Диалоги
        self.dialogue_sequence.draw(screen)
        
    def is_complete(self):
        """Проверка завершения диалога"""
        return self.dialogue_sequence.is_complete
