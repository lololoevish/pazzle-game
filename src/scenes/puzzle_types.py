"""
Различные типы головоломок для игры
"""
import pygame
import random
import string


class MazePuzzle:
    """Головоломка-лабиринт"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        self.cell_size = 40
        self.cols = 15
        self.rows = 12
        
        # Генерация лабиринта
        self.maze = self.generate_maze()
        
        # Позиция игрока в лабиринте
        self.player_col = 1
        self.player_row = 1
        
        # Выход
        self.exit_col = self.cols - 2
        self.exit_row = self.rows - 2
        
        self.solved = False
        
    def generate_maze(self):
        """Генерация простого лабиринта"""
        maze = [[1 for _ in range(self.cols)] for _ in range(self.rows)]
        
        # Создаём проходы
        def carve(x, y):
            maze[y][x] = 0
            directions = [(0, -2), (2, 0), (0, 2), (-2, 0)]
            random.shuffle(directions)
            
            for dx, dy in directions:
                nx, ny = x + dx, y + dy
                if 0 < nx < self.cols - 1 and 0 < ny < self.rows - 1 and maze[ny][nx] == 1:
                    maze[y + dy//2][x + dx//2] = 0
                    carve(nx, ny)
        
        carve(1, 1)
        maze[1][1] = 0
        maze[self.rows - 2][self.cols - 2] = 0
        
        return maze
        
    def handle_input(self, keys_pressed):
        """Обработка движения в лабиринте"""
        if keys_pressed[pygame.K_UP] or keys_pressed[pygame.K_w]:
            if self.player_row > 0 and self.maze[self.player_row - 1][self.player_col] == 0:
                self.player_row -= 1
        elif keys_pressed[pygame.K_DOWN] or keys_pressed[pygame.K_s]:
            if self.player_row < self.rows - 1 and self.maze[self.player_row + 1][self.player_col] == 0:
                self.player_row += 1
        elif keys_pressed[pygame.K_LEFT] or keys_pressed[pygame.K_a]:
            if self.player_col > 0 and self.maze[self.player_row][self.player_col - 1] == 0:
                self.player_col -= 1
        elif keys_pressed[pygame.K_RIGHT] or keys_pressed[pygame.K_d]:
            if self.player_col < self.cols - 1 and self.maze[self.player_row][self.player_col + 1] == 0:
                self.player_col += 1
                
        # Проверка достижения выхода
        if self.player_col == self.exit_col and self.player_row == self.exit_row:
            self.solved = True
            
    def draw(self, screen):
        """Отрисовка лабиринта"""
        offset_x = (self.screen_width - self.cols * self.cell_size) // 2
        offset_y = (self.screen_height - self.rows * self.cell_size) // 2
        
        for row in range(self.rows):
            for col in range(self.cols):
                x = offset_x + col * self.cell_size
                y = offset_y + row * self.cell_size
                
                if self.maze[row][col] == 1:
                    # Стена
                    pygame.draw.rect(screen, (60, 60, 80), (x, y, self.cell_size, self.cell_size))
                else:
                    # Проход
                    pygame.draw.rect(screen, (200, 200, 220), (x, y, self.cell_size, self.cell_size))
                    
                # Сетка
                pygame.draw.rect(screen, (100, 100, 120), (x, y, self.cell_size, self.cell_size), 1)
        
        # Игрок
        player_x = offset_x + self.player_col * self.cell_size + self.cell_size // 2
        player_y = offset_y + self.player_row * self.cell_size + self.cell_size // 2
        pygame.draw.circle(screen, (100, 150, 255), (player_x, player_y), self.cell_size // 3)
        
        # Выход
        exit_x = offset_x + self.exit_col * self.cell_size + self.cell_size // 2
        exit_y = offset_y + self.exit_row * self.cell_size + self.cell_size // 2
        pygame.draw.circle(screen, (255, 215, 0), (exit_x, exit_y), self.cell_size // 3)


class WordSearchPuzzle:
    """Головоломка - поиск слова"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        
        # Слова для поиска
        self.words = ['ИГРА', 'КОД', 'ПАЗЛ', 'КВЕСТ']
        self.current_word_index = 0
        self.current_word = self.words[self.current_word_index]
        
        # Сетка букв
        self.grid_size = 8
        self.cell_size = 60
        self.grid = self.generate_grid()
        
        # Найденные буквы
        self.found_positions = []
        self.solved = False
        
        self.font = pygame.font.SysFont('arial', 24, bold=True)
        
    def generate_grid(self):
        """Генерация сетки с буквами"""
        grid = [[random.choice('АБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЭЮЯ') 
                for _ in range(self.grid_size)] 
                for _ in range(self.grid_size)]
        
        # Размещаем слово горизонтально
        row = random.randint(0, self.grid_size - 1)
        col = random.randint(0, self.grid_size - len(self.current_word))
        
        for i, letter in enumerate(self.current_word):
            grid[row][col + i] = letter
            
        self.word_positions = [(row, col + i) for i in range(len(self.current_word))]
        
        return grid
        
    def handle_click(self, mouse_pos):
        """Обработка клика по букве"""
        offset_x = (self.screen_width - self.grid_size * self.cell_size) // 2
        offset_y = (self.screen_height - self.grid_size * self.cell_size) // 2 + 50
        
        mx, my = mouse_pos
        col = (mx - offset_x) // self.cell_size
        row = (my - offset_y) // self.cell_size
        
        if 0 <= row < self.grid_size and 0 <= col < self.grid_size:
            if (row, col) in self.word_positions and (row, col) not in self.found_positions:
                self.found_positions.append((row, col))
                
                # Проверка завершения
                if len(self.found_positions) == len(self.current_word):
                    self.current_word_index += 1
                    if self.current_word_index >= len(self.words):
                        self.solved = True
                    else:
                        self.current_word = self.words[self.current_word_index]
                        self.grid = self.generate_grid()
                        self.found_positions = []
                        
    def draw(self, screen):
        """Отрисовка головоломки"""
        # Заголовок
        title = self.font.render(f"Найдите слово: {self.current_word}", True, (255, 255, 255))
        title_rect = title.get_rect(center=(self.screen_width // 2, 30))
        screen.blit(title, title_rect)
        
        # Сетка
        offset_x = (self.screen_width - self.grid_size * self.cell_size) // 2
        offset_y = (self.screen_height - self.grid_size * self.cell_size) // 2 + 50
        
        for row in range(self.grid_size):
            for col in range(self.grid_size):
                x = offset_x + col * self.cell_size
                y = offset_y + row * self.cell_size
                
                # Фон ячейки
                if (row, col) in self.found_positions:
                    color = (100, 255, 100)
                else:
                    color = (80, 80, 100)
                    
                pygame.draw.rect(screen, color, (x, y, self.cell_size, self.cell_size))
                pygame.draw.rect(screen, (200, 200, 200), (x, y, self.cell_size, self.cell_size), 2)
                
                # Буква
                letter = self.font.render(self.grid[row][col], True, (255, 255, 255))
                letter_rect = letter.get_rect(center=(x + self.cell_size // 2, y + self.cell_size // 2))
                screen.blit(letter, letter_rect)
        
        # Прогресс
        progress = self.font.render(f"Слово {self.current_word_index + 1}/{len(self.words)}", 
                                    True, (255, 255, 255))
        screen.blit(progress, (20, self.screen_height - 40))


class PatternPuzzle:
    """Головоломка - повтори паттерн"""
    
    def __init__(self, screen_width, screen_height):
        self.screen_width = screen_width
        self.screen_height = screen_height
        
        # Кнопки
        self.buttons = [
            {'pos': (200, 300), 'color': (255, 100, 100), 'id': 0},
            {'pos': (350, 300), 'color': (100, 255, 100), 'id': 1},
            {'pos': (500, 300), 'color': (100, 100, 255), 'id': 2},
            {'pos': (650, 300), 'color': (255, 255, 100), 'id': 3}
        ]
        
        self.button_radius = 50
        
        # Паттерн
        self.pattern = []
        self.player_input = []
        self.showing_pattern = False
        self.show_index = 0
        self.show_timer = 0
        self.round = 1
        self.max_rounds = 5
        
        self.generate_pattern()
        self.solved = False
        
        self.font = pygame.font.SysFont('arial', 24, bold=True)
        
    def generate_pattern(self):
        """Генерация нового паттерна"""
        self.pattern = [random.randint(0, 3) for _ in range(self.round + 2)]
        self.player_input = []
        self.showing_pattern = True
        self.show_index = 0
        self.show_timer = 60
        
    def update(self):
        """Обновление показа паттерна"""
        if self.showing_pattern:
            self.show_timer -= 1
            if self.show_timer <= 0:
                self.show_index += 1
                if self.show_index >= len(self.pattern):
                    self.showing_pattern = False
                else:
                    self.show_timer = 60
                    
    def handle_click(self, mouse_pos):
        """Обработка клика по кнопке"""
        if self.showing_pattern:
            return
            
        for button in self.buttons:
            dx = mouse_pos[0] - button['pos'][0]
            dy = mouse_pos[1] - button['pos'][1]
            if dx*dx + dy*dy <= self.button_radius * self.button_radius:
                self.player_input.append(button['id'])
                
                # Проверка
                if len(self.player_input) <= len(self.pattern):
                    if self.player_input[-1] != self.pattern[len(self.player_input) - 1]:
                        # Ошибка - начать заново
                        self.player_input = []
                    elif len(self.player_input) == len(self.pattern):
                        # Раунд пройден
                        self.round += 1
                        if self.round > self.max_rounds:
                            self.solved = True
                        else:
                            self.generate_pattern()
                            
    def draw(self, screen):
        """Отрисовка головоломки"""
        # Заголовок
        title = self.font.render(f"Повторите паттерн - Раунд {self.round}/{self.max_rounds}", 
                                True, (255, 255, 255))
        title_rect = title.get_rect(center=(self.screen_width // 2, 50))
        screen.blit(title, title_rect)
        
        # Кнопки
        for i, button in enumerate(self.buttons):
            # Подсветка при показе паттерна
            if self.showing_pattern and self.show_index < len(self.pattern):
                if i == self.pattern[self.show_index] and self.show_timer > 30:
                    color = tuple(min(c + 100, 255) for c in button['color'])
                else:
                    color = button['color']
            else:
                color = button['color']
                
            pygame.draw.circle(screen, color, button['pos'], self.button_radius)
            pygame.draw.circle(screen, (255, 255, 255), button['pos'], self.button_radius, 3)
        
        # Прогресс ввода
        if not self.showing_pattern:
            progress_text = f"Введено: {len(self.player_input)}/{len(self.pattern)}"
            progress = self.font.render(progress_text, True, (255, 255, 255))
            screen.blit(progress, (20, self.screen_height - 40))
