use macroquad::prelude::*;
use rand::Rng;

pub struct MazePuzzle {
    width: usize,
    height: usize,
    grid: Vec<Vec<bool>>, // true = стена, false = проход
    player_x: usize,
    player_y: usize,
    exit_x: usize,
    exit_y: usize,
    solved: bool,
}

impl MazePuzzle {
    pub fn new(width: usize, height: usize) -> Self {
        let mut puzzle = Self {
            width,
            height,
            grid: vec![vec![true; width]; height],
            player_x: 1,
            player_y: 1,
            exit_x: width - 2,
            exit_y: height - 2,
            solved: false,
        };
        
        puzzle.generate_maze();
        puzzle
    }
    
    fn generate_maze(&mut self) {
        // Простая генерация лабиринта (DFS)
        let mut rng = rand::thread_rng();
        let mut stack = vec![(1, 1)];
        self.grid[1][1] = false;
        
        while let Some((x, y)) = stack.last().copied() {
            let mut neighbors = Vec::new();
            
            // Проверяем соседей
            for (dx, dy) in [(0, -2), (2, 0), (0, 2), (-2, 0)] {
                let nx = x as i32 + dx;
                let ny = y as i32 + dy;
                
                if nx > 0 && ny > 0 && 
                   nx < self.width as i32 - 1 && 
                   ny < self.height as i32 - 1 &&
                   self.grid[ny as usize][nx as usize] {
                    neighbors.push((nx as usize, ny as usize, dx, dy));
                }
            }
            
            if neighbors.is_empty() {
                stack.pop();
            } else {
                let (nx, ny, dx, dy) = neighbors[rng.gen_range(0..neighbors.len())];
                
                // Убираем стену между текущей и следующей клеткой
                let wall_x = (x as i32 + dx / 2) as usize;
                let wall_y = (y as i32 + dy / 2) as usize;
                self.grid[wall_y][wall_x] = false;
                self.grid[ny][nx] = false;
                
                stack.push((nx, ny));
            }
        }
        
        // Убеждаемся, что выход доступен
        self.grid[self.exit_y][self.exit_x] = false;
    }
    
    pub fn handle_input(&mut self) {
        if self.solved {
            return;
        }
        
        let mut new_x = self.player_x;
        let mut new_y = self.player_y;
        
        if is_key_pressed(KeyCode::W) || is_key_pressed(KeyCode::Up) {
            new_y = new_y.saturating_sub(1);
        }
        if is_key_pressed(KeyCode::S) || is_key_pressed(KeyCode::Down) {
            new_y = (new_y + 1).min(self.height - 1);
        }
        if is_key_pressed(KeyCode::A) || is_key_pressed(KeyCode::Left) {
            new_x = new_x.saturating_sub(1);
        }
        if is_key_pressed(KeyCode::D) || is_key_pressed(KeyCode::Right) {
            new_x = (new_x + 1).min(self.width - 1);
        }
        
        // Проверка столкновения со стеной
        if !self.grid[new_y][new_x] {
            self.player_x = new_x;
            self.player_y = new_y;
            
            // Проверка достижения выхода
            if self.player_x == self.exit_x && self.player_y == self.exit_y {
                self.solved = true;
            }
        }
    }
    
    pub fn update(&mut self) {
        // Пока ничего не делаем
    }
    
    pub fn draw(&self) {
        let cell_size = 30.0;
        let offset_x = (screen_width() - self.width as f32 * cell_size) / 2.0;
        let offset_y = (screen_height() - self.height as f32 * cell_size) / 2.0 + 30.0;
        
        // Рисуем сетку
        for y in 0..self.height {
            for x in 0..self.width {
                let px = offset_x + x as f32 * cell_size;
                let py = offset_y + y as f32 * cell_size;
                
                let color = if self.grid[y][x] {
                    Color::from_rgba(60, 60, 80, 255) // Стена
                } else {
                    Color::from_rgba(200, 200, 220, 255) // Проход
                };
                
                draw_rectangle(px, py, cell_size - 2.0, cell_size - 2.0, color);
            }
        }
        
        // Рисуем старт (зелёный)
        let start_x = offset_x + 1.0 * cell_size;
        let start_y = offset_y + 1.0 * cell_size;
        draw_rectangle(start_x, start_y, cell_size - 2.0, cell_size - 2.0, GREEN);
        
        // Рисуем выход (красный)
        let exit_x = offset_x + self.exit_x as f32 * cell_size;
        let exit_y = offset_y + self.exit_y as f32 * cell_size;
        draw_rectangle(exit_x, exit_y, cell_size - 2.0, cell_size - 2.0, RED);
        
        // Рисуем игрока (синий круг)
        let player_x = offset_x + self.player_x as f32 * cell_size + cell_size / 2.0;
        let player_y = offset_y + self.player_y as f32 * cell_size + cell_size / 2.0;
        draw_circle(player_x, player_y, cell_size / 3.0, BLUE);
        
        // Подсказка
        draw_text("WASD - движение", 20.0, 60.0, 20.0, WHITE);
    }
    
    pub fn is_solved(&self) -> bool {
        self.solved
    }
}
