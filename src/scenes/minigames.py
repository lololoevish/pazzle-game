import pygame
import random
import math


class NPC:
    """Класс NPC для города"""
    def __init__(self, x, y, name, description, minigame_type, reward):
        self.x = x
        self.y = y
        self.width = 30
        self.height = 60
        self.name = name
        self.description = description
        self.minigame_type = minigame_type  # 'rps', 'quiz', 'duel', 'gacha'
        self.reward = reward  # Что даёт за победу
        self.dialog_active = False
        self.color_head = (220, 180, 140)
        self.color_body = (100, 80, 60)
        
    def draw(self, screen):
        """Отрисовка NPC"""
        # Тело
        pygame.draw.rect(screen, self.color_body, 
                        (self.x, self.y + 20, self.width, self.height - 20))
        
        # Голова
        pygame.draw.circle(screen, self.color_head,
                         (self.x + self.width // 2, self.y + 10), 12)
        
        # Глаза
        pygame.draw.circle(screen, (0, 0, 0),
                         (self.x + self.width // 2 - 4, self.y + 8), 2)
        pygame.draw.circle(screen, (0, 0, 0),
                         (self.x + self.width // 2 + 4, self.y + 8), 2)
                         
    def get_rect(self):
        """Получить прямоугольник NPC"""
        return pygame.Rect(self.x, self.y, self.width, self.height)


class MiniGameScene:
    """Сцена мини-игры"""
    
    def __init__(self, screen_width, screen_height, npc, player_inventory):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.npc = npc
        self.player_inventory = player_inventory
        
        # Результат
        self.result = None  # 'win', 'lose', 'back'
        self.reward_given = False
        
        # Шрифты
        self.font_title = pygame.font.SysFont('fantasy', 36, bold=True)
        self.font_text = pygame.font.SysFont('arial', 20)
        self.font_button = pygame.font.SysFont('arial', 24, bold=True)
        
        # Мини-игры
        if npc.minigame_type == 'rps':
            self.init_rps()
        elif npc.minigame_type == 'quiz':
            self.init_quiz()
        elif npc.minigame_type == 'duel':
            self.init_duel()
        elif npc.minigame_type == 'gacha':
            self.init_gacha()
            
    def init_rps(self):
        """Инициализация игры Камень-Ножницы-Бумага"""
        self.game_type = 'rps'
        self.choices = ['Камень', 'Ножницы', 'Бумага']
        self.player_choice = None
        self.npc_choice = None
        self.round_result = None
        self.player_score = 0
        self.npc_score = 0
        self.rounds_to_win = 3
        self.game_over = False
        self.message = "Выберите ваш ход!"
        
    def init_quiz(self):
        """Инициализация викторины"""
        self.game_type = 'quiz'
        self.questions = [
            {"q": "Сколько уровней в игре?", "a": "6", "options": ["3", "6", "9"]},
            {"q": "Как зовут главного героя?", "a": "Искатель", "options": ["Герой", "Искатель", "Путешественник"]},
            {"q": "Что ищет игрок в подземельях?", "a": "Артефакт", "options": ["Сокровище", "Артефакт", "Ключ"]},
            {"q": "Сколько головоломок в первом уровне?", "a": "3", "options": ["2", "3", "4"]},
            {"q": "Какого цвета рубин в игре?", "a": "Красный", "options": ["Красный", "Зелёный", "Синий"]}
        ]
        self.current_question = 0
        self.question_over = False
        self.correct_answers = 0
        self.total_questions = 3
        self.selected_option = None
        random.shuffle(self.questions)
        self.questions = self.questions[:self.total_questions]
        
    def init_duel(self):
        """Инициализация дуэли (пошаговая как покемоны)"""
        self.game_type = 'duel'
        # Игрок и противник
        self.player_hp = 100
        self.player_max_hp = 100
        self.npc_hp = 100
        self.npc_max_hp = 100
        self.turn = 'player'  # 'player' или 'npc'
        self.battle_over = False
        self.winner = None
        self.message = "Ваш ход! Выберите действие"
        self.attack_animation = None
        self.damage_display = None
        self.damage_timer = 0
        
        # Атаки
        self.player_attacks = [
            {"name": "Удар мечом", "damage": 20, "accuracy": 90},
            {"name": "Огненный шар", "damage": 30, "accuracy": 70},
            {"name": "Лечение", "damage": -25, "accuracy": 100}
        ]
        
    def init_gacha(self):
        """Инициализация гача-автомата"""
        self.game_type = 'gacha'
        self.pulls = 0
        self.max_pulls = 3
        self.prize = None
        self.spinning = False
        self.spin_timer = 0
        self.prize_displayed = False
        
        # Призы
        self.prizes = [
            {"name": "Золото x100", "rarity": "common", "color": (200, 200, 200)},
            {"name": "Зелье здоровья", "rarity": "uncommon", "color": (100, 255, 100)},
            {"name": "Свиток силы", "rarity": "rare", "color": (100, 100, 255)},
            {"name": "Легендарный ключ", "rarity": "epic", "color": (255, 215, 0)},
            {"name": "Артефакт удачи", "rarity": "legendary", "color": (255, 50, 150)}
        ]
        
    def handle_events(self, events):
        """Обработка событий"""
        for event in events:
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    self.result = 'back'
                    return
                    
                if self.game_type == 'rps' and not self.game_over:
                    if event.key == pygame.K_1:
                        self.play_rps(0)
                    elif event.key == pygame.K_2:
                        self.play_rps(1)
                    elif event.key == pygame.K_3:
                        self.play_rps(2)
                        
                elif self.game_type == 'quiz' and not self.question_over:
                    if event.key == pygame.K_1:
                        self.check_answer(0)
                    elif event.key == pygame.K_2:
                        self.check_answer(1)
                    elif event.key == pygame.K_3:
                        self.check_answer(2)
                        
                elif self.game_type == 'duel' and not self.battle_over and self.turn == 'player':
                    if event.key == pygame.K_1:
                        self.player_attack(0)
                    elif event.key == pygame.K_2:
                        self.player_attack(1)
                    elif event.key == pygame.K_3:
                        self.player_attack(2)
                        
                elif self.game_type == 'gacha' and not self.spinning and self.pulls < self.max_pulls:
                    if event.key == pygame.K_SPACE:
                        self.do_gacha_pull()
                        
    def play_rps(self, player_idx):
        """Игра в камень-ножницы-бумагу"""
        self.player_choice = player_idx
        self.npc_choice = random.randint(0, 2)
        
        # Определение победителя
        diff = (self.player_choice - self.npc_choice) % 3
        if diff == 0:
            self.round_result = 'draw'
            self.message = "Ничья!"
        elif diff == 1:
            self.npc_score += 1
            self.round_result = 'lose'
            self.message = "Вы проиграли раунд!"
        else:
            self.player_score += 1
            self.round_result = 'win'
            self.message = "Вы выиграли раунд!"
            
        # Проверка окончания игры
        if self.player_score >= self.rounds_to_win:
            self.game_over = True
            self.result = 'win'
            self.message = "ПОБЕДА! Вы выиграли игру!"
        elif self.npc_score >= self.rounds_to_win:
            self.game_over = True
            self.result = 'lose'
            self.message = "Поражение! NPC выиграл игру"
            
    def check_answer(self, option_idx):
        """Проверка ответа в викторине"""
        q = self.questions[self.current_question]
        selected = q['options'][option_idx]
        
        if selected == q['a']:
            self.correct_answers += 1
            self.message = "Правильно!"
        else:
            self.message = f"Неправильно! Правильный ответ: {q['a']}"
            
        self.selected_option = option_idx
        
        # Задержка перед следующим вопросом
        pygame.time.wait(1000)
        
        self.current_question += 1
        self.selected_option = None
        
        if self.current_question >= self.total_questions:
            self.question_over = True
            if self.correct_answers >= 2:
                self.result = 'win'
                self.message = f"ПОБЕДА! Правильных ответов: {self.correct_answers}/{self.total_questions}"
            else:
                self.result = 'lose'
                self.message = f"Поражение! Правильных ответов: {self.correct_answers}/{self.total_questions}"
                
    def player_attack(self, attack_idx):
        """Атака игрока в дуэли"""
        attack = self.player_attacks[attack_idx]
        
        # Проверка точности
        if random.randint(1, 100) <= attack['accuracy']:
            damage = attack['damage']
            if damage < 0:
                # Лечение
                self.player_hp = min(self.player_max_hp, self.player_hp - damage)
                self.message = f"Вы использовали {attack['name']}! +{-damage} HP"
            else:
                # Атака
                self.npc_hp = max(0, self.npc_hp - damage)
                self.message = f"Вы использовали {attack['name']}! -{damage} HP NPC"
                self.attack_animation = {'target': 'npc', 'damage': damage}
        else:
            self.message = f"Вы промахнулись ({attack['name']})!"
            
        self.damage_timer = 30
        
        # Проверка победы
        if self.npc_hp <= 0:
            self.battle_over = True
            self.winner = 'player'
            self.result = 'win'
            self.message = "ПОБЕДА! NPC повержен!"
            return
            
        # Ход NPC
        self.turn = 'npc'
        pygame.time.wait(500)
        self.npc_turn()
        
    def npc_turn(self):
        """Ход NPC в дуэли"""
        npc_attacks = [
            {"name": "Удар", "damage": 15, "accuracy": 85},
            {"name": "Ледяная стрела", "damage": 25, "accuracy": 65},
            {"name": "Щит", "damage": 0, "accuracy": 100}
        ]
        
        attack = random.choice(npc_attacks)
        
        if random.randint(1, 100) <= attack['accuracy']:
            damage = attack['damage']
            if damage > 0:
                self.player_hp = max(0, self.player_hp - damage)
                self.message = f"NPC использует {attack['name']}! -{damage} HP"
                self.attack_animation = {'target': 'player', 'damage': damage}
            else:
                self.message = f"NPC использует {attack['name']}!"
        else:
            self.message = f"NPC промахнулся ({attack['name']})!"
            
        self.damage_timer = 30
        
        # Проверка поражения
        if self.player_hp <= 0:
            self.battle_over = True
            self.winner = 'npc'
            self.result = 'lose'
            self.message = "Поражение! Вы проиграли битву!"
            return
            
        self.turn = 'player'
        
    def do_gacha_pull(self):
        """Вытянуть приз из гачи"""
        self.spinning = True
        self.spin_timer = 60
        self.pulls += 1
        
    def update(self):
        """Обновление состояния"""
        if self.game_type == 'rps' and self.round_result and not self.game_over:
            # Задержка перед следующим раундом
            pygame.time.wait(1000)
            self.round_result = None
            self.player_choice = None
            self.npc_choice = None
            self.message = "Выберите ваш ход!"
            
        elif self.game_type == 'gacha' and self.spinning:
            self.spin_timer -= 1
            if self.spin_timer <= 0:
                self.spinning = False
                # Определение приза
                roll = random.random()
                if roll < 0.5:
                    prize = self.prizes[0]  # common
                elif roll < 0.75:
                    prize = self.prizes[1]  # uncommon
                elif roll < 0.9:
                    prize = self.prizes[2]  # rare
                elif roll < 0.97:
                    prize = self.prizes[3]  # epic
                else:
                    prize = self.prizes[4]  # legendary
                    
                self.prize = prize
                self.prize_displayed = True
                
                if self.pulls >= self.max_pulls:
                    self.result = 'win' if prize['rarity'] in ['rare', 'epic', 'legendary'] else 'lose'
                    
        elif self.game_type == 'duel' and self.damage_timer > 0:
            self.damage_timer -= 1
            
    def draw(self, screen):
        """Отрисовка мини-игры"""
        # Фон
        screen.fill((20, 20, 40))
        
        # Заголовок
        title = self.font_title.render(f"Мини-игра: {self.npc.name}", True, (255, 215, 0))
        screen.blit(title, (self.screen_width // 2 - title.get_width() // 2, 20))
        
        if self.game_type == 'rps':
            self.draw_rps(screen)
        elif self.game_type == 'quiz':
            self.draw_quiz(screen)
        elif self.game_type == 'duel':
            self.draw_duel(screen)
        elif self.game_type == 'gacha':
            self.draw_gacha(screen)
            
        # Кнопка возврата
        back_text = self.font_text.render("ESC - Вернуться в город", True, (150, 150, 150))
        screen.blit(back_text, (10, self.screen_height - 30))
        
    def draw_rps(self, screen):
        """Отрисовка RPS"""
        # Счёт
        score_text = self.font_text.render(f"Вы: {self.player_score} | NPC: {self.npc_score}", True, (255, 255, 255))
        screen.blit(score_text, (self.screen_width // 2 - score_text.get_width() // 2, 80))
        
        # Сообщение
        msg = self.font_text.render(self.message, True, (200, 200, 100))
        screen.blit(msg, (self.screen_width // 2 - msg.get_width() // 2, 120))
        
        if not self.game_over:
            # Кнопки выбора
            y = 180
            for i, choice in enumerate(self.choices):
                color = (100, 150, 200) if self.player_choice != i else (150, 200, 250)
                rect = pygame.Rect(self.screen_width // 2 - 100, y + i * 60, 200, 50)
                pygame.draw.rect(screen, color, rect, border_radius=10)
                pygame.draw.rect(screen, (255, 255, 255), rect, 2, border_radius=10)
                
                text = self.font_button.render(f"{i+1}. {choice}", True, (255, 255, 255))
                screen.blit(text, (rect.x + 20, rect.y + 12))
        else:
            # Конец игры
            result_color = (100, 255, 100) if self.result == 'win' else (255, 100, 100)
            result_text = self.font_title.render(self.message, True, result_color)
            screen.blit(result_text, (self.screen_width // 2 - result_text.get_width() // 2, 200))
            
    def draw_quiz(self, screen):
        """Отрисовка викторины"""
        if self.question_over:
            result_color = (100, 255, 100) if self.result == 'win' else (255, 100, 100)
            result_text = self.font_title.render(self.message, True, result_color)
            screen.blit(result_text, (self.screen_width // 2 - result_text.get_width() // 2, 200))
            return
            
        q = self.questions[self.current_question]
        
        # Вопрос
        q_text = self.font_title.render(q['q'], True, (255, 255, 255))
        screen.blit(q_text, (self.screen_width // 2 - q_text.get_width() // 2, 80))
        
        # Ответы
        y = 180
        for i, option in enumerate(q['options']):
            color = (80, 120, 180)
            if self.selected_option == i:
                color = (100, 255, 100) if option == q['a'] else (255, 100, 100)
                
            rect = pygame.Rect(self.screen_width // 2 - 150, y + i * 70, 300, 55)
            pygame.draw.rect(screen, color, rect, border_radius=10)
            pygame.draw.rect(screen, (255, 255, 255), rect, 2, border_radius=10)
            
            text = self.font_button.render(f"{i+1}. {option}", True, (255, 255, 255))
            screen.blit(text, (rect.x + 20, rect.y + 12))
            
    def draw_duel(self, screen):
        """Отрисовка дуэли"""
        # HP игрока
        pygame.draw.rect(screen, (50, 50, 50), (50, 100, 250, 30))
        pygame.draw.rect(screen, (100, 255, 100), (50, 100, 250 * (self.player_hp / self.player_max_hp), 30))
        hp_text = self.font_text.render(f"HP: {self.player_hp}/{self.player_max_hp}", True, (255, 255, 255))
        screen.blit(hp_text, (60, 105))
        
        # HP NPC
        pygame.draw.rect(screen, (50, 50, 50), (500, 100, 250, 30))
        pygame.draw.rect(screen, (255, 100, 100), (500, 100, 250 * (self.npc_hp / self.npc_max_hp), 30))
        hp_text = self.font_text.render(f"HP: {self.npc_hp}/{self.npc_max_hp}", True, (255, 255, 255))
        screen.blit(hp_text, (510, 105))
        
        # Имена
        player_name = self.font_text.render("ВЫ", True, (100, 200, 255))
        screen.blit(player_name, (150, 70))
        
        npc_name = self.font_text.render(self.npc.name, True, (255, 100, 100))
        screen.blit(npc_name, (550, 70))
        
        # Сообщение
        msg = self.font_text.render(self.message, True, (255, 255, 100))
        screen.blit(msg, (self.screen_width // 2 - msg.get_width() // 2, 150))
        
        if not self.battle_over and self.turn == 'player':
            # Атаки
            y = 250
            for i, attack in enumerate(self.player_attacks):
                color = (80, 120, 180)
                rect = pygame.Rect(self.screen_width // 2 - 150, y + i * 70, 300, 55)
                pygame.draw.rect(screen, color, rect, border_radius=10)
                pygame.draw.rect(screen, (255, 255, 255), rect, 2, border_radius=10)
                
                dmg_text = f"{attack['damage']}" if attack['damage'] > 0 else f"+{-attack['damage']}"
                text = self.font_button.render(f"{i+1}. {attack['name']} ({dmg_text})", True, (255, 255, 255))
                screen.blit(text, (rect.x + 20, rect.y + 12))
        elif self.battle_over:
            result_color = (100, 255, 100) if self.result == 'win' else (255, 100, 100)
            result_text = self.font_title.render(self.message, True, result_color)
            screen.blit(result_text, (self.screen_width // 2 - result_text.get_width() // 2, 300))
            
    def draw_gacha(self, screen):
        """Отрисовка гачи"""
        # Оставшиеся попытки
        pulls_text = self.font_text.render(f"Осталось попыток: {self.max_pulls - self.pulls}", True, (255, 255, 255))
        screen.blit(pulls_text, (self.screen_width // 2 - pulls_text.get_width() // 2, 80))
        
        if self.spinning:
            spin_text = self.font_title.render("ВЫТЯГИВАЕМ...", True, (255, 215, 0))
            screen.blit(spin_text, (self.screen_width // 2 - spin_text.get_width() // 2, 200))
            
        elif self.prize_displayed and self.prize:
            # Показ приза
            prize_text = self.font_title.render(f"ВЫ ПОЛУЧИЛИ:", True, (255, 255, 255))
            screen.blit(prize_text, (self.screen_width // 2 - prize_text.get_width() // 2, 180))
            
            name_text = self.font_title.render(self.prize['name'], True, self.prize['color'])
            screen.blit(name_text, (self.screen_width // 2 - name_text.get_width() // 2, 240))
            
            rarity_text = self.font_text.render(f"Редкость: {self.prize['rarity'].upper()}", True, self.prize['color'])
            screen.blit(rarity_text, (self.screen_width // 2 - rarity_text.get_width() // 2, 300))
            
            if self.pulls >= self.max_pulls:
                if self.result == 'win':
                    win_text = self.font_title.render("ПОЗДРАВЛЯЕМ!", True, (255, 215, 0))
                    screen.blit(win_text, (self.screen_width // 2 - win_text.get_width() // 2, 400))
                    
        elif self.pulls < self.max_pulls:
            # Кнопка
            rect = pygame.Rect(self.screen_width // 2 - 100, 250, 200, 60)
            pygame.draw.rect(screen, (150, 50, 200), rect, border_radius=15)
            pygame.draw.rect(screen, (255, 255, 255), rect, 3, border_radius=15)
            
            text = self.font_button.render("ПОТЯНУТЬ (SPACE)", True, (255, 255, 255))
            screen.blit(text, (rect.x + 10, rect.y + 15))
            
    def is_complete(self):
        """Проверка завершения"""
        return self.result is not None
        
    def get_reward(self):
        """Получить награду"""
        if self.result == 'win' and not self.reward_given:
            self.reward_given = True
            return self.npc.reward
        return None
