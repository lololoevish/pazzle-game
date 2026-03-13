use ::rand::{thread_rng, Rng};
use macroquad::prelude::*;

pub struct MazePuzzle {
    width: usize,
    height: usize,
    grid: Vec<Vec<bool>>,
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
        let mut rng = thread_rng();
        let mut stack = vec![(1, 1)];
        self.grid[1][1] = false;

        while let Some((x, y)) = stack.last().copied() {
            let mut neighbors = Vec::new();

            for (dx, dy) in [(0, -2), (2, 0), (0, 2), (-2, 0)] {
                let nx = x as i32 + dx;
                let ny = y as i32 + dy;

                if nx > 0
                    && ny > 0
                    && nx < self.width as i32 - 1
                    && ny < self.height as i32 - 1
                    && self.grid[ny as usize][nx as usize]
                {
                    neighbors.push((nx as usize, ny as usize, dx, dy));
                }
            }

            if neighbors.is_empty() {
                stack.pop();
            } else {
                let (nx, ny, dx, dy) = neighbors[rng.gen_range(0..neighbors.len())];
                let wall_x = (x as i32 + dx / 2) as usize;
                let wall_y = (y as i32 + dy / 2) as usize;
                self.grid[wall_y][wall_x] = false;
                self.grid[ny][nx] = false;
                stack.push((nx, ny));
            }
        }

        self.grid[self.exit_y][self.exit_x] = false;
    }

    fn slide_destination(
        &self,
        start_x: usize,
        start_y: usize,
        dx: i32,
        dy: i32,
    ) -> (usize, usize) {
        let mut x = start_x as i32;
        let mut y = start_y as i32;

        loop {
            let next_x = x + dx;
            let next_y = y + dy;

            if next_x < 0
                || next_y < 0
                || next_x >= self.width as i32
                || next_y >= self.height as i32
                || self.grid[next_y as usize][next_x as usize]
            {
                break;
            }

            x = next_x;
            y = next_y;
        }

        (x as usize, y as usize)
    }

    pub fn handle_input(&mut self) {
        if self.solved {
            return;
        }

        let direction = if is_key_pressed(KeyCode::W) || is_key_pressed(KeyCode::Up) {
            Some((0, -1))
        } else if is_key_pressed(KeyCode::S) || is_key_pressed(KeyCode::Down) {
            Some((0, 1))
        } else if is_key_pressed(KeyCode::A) || is_key_pressed(KeyCode::Left) {
            Some((-1, 0))
        } else if is_key_pressed(KeyCode::D) || is_key_pressed(KeyCode::Right) {
            Some((1, 0))
        } else {
            None
        };

        if let Some((dx, dy)) = direction {
            let (new_x, new_y) = self.slide_destination(self.player_x, self.player_y, dx, dy);
            self.player_x = new_x;
            self.player_y = new_y;

            if self.player_x == self.exit_x && self.player_y == self.exit_y {
                self.solved = true;
            }
        }
    }

    pub fn update(&mut self) {}

    pub fn draw(&self) {
        let cell_size = 30.0;
        let offset_x = (screen_width() - self.width as f32 * cell_size) / 2.0;
        let offset_y = (screen_height() - self.height as f32 * cell_size) / 2.0 + 30.0;

        for y in 0..self.height {
            for x in 0..self.width {
                let px = offset_x + x as f32 * cell_size;
                let py = offset_y + y as f32 * cell_size;

                let color = if self.grid[y][x] {
                    Color::from_rgba(56, 66, 88, 255)
                } else {
                    Color::from_rgba(205, 214, 228, 255)
                };

                draw_rectangle(px, py, cell_size - 2.0, cell_size - 2.0, color);
                if !self.grid[y][x] {
                    draw_rectangle(
                        px,
                        py + cell_size - 10.0,
                        cell_size - 2.0,
                        8.0,
                        Color::from_rgba(182, 190, 208, 255),
                    );
                }
            }
        }

        let start_x = offset_x + cell_size;
        let start_y = offset_y + cell_size;
        draw_rectangle(start_x, start_y, cell_size - 2.0, cell_size - 2.0, GREEN);

        let exit_x = offset_x + self.exit_x as f32 * cell_size;
        let exit_y = offset_y + self.exit_y as f32 * cell_size;
        draw_rectangle(exit_x, exit_y, cell_size - 2.0, cell_size - 2.0, RED);
        draw_circle(
            exit_x + cell_size / 2.0,
            exit_y + cell_size / 2.0,
            8.0,
            Color::from_rgba(255, 220, 160, 255),
        );

        let player_x = offset_x + self.player_x as f32 * cell_size + cell_size / 2.0;
        let player_y = offset_y + self.player_y as f32 * cell_size + cell_size / 2.0;
        draw_circle(player_x, player_y, cell_size / 3.0, BLUE);
        draw_circle_lines(player_x, player_y, cell_size / 3.0, 3.0, WHITE);

        draw_text(
            "WASD - скольжение до ближайшей стены",
            20.0,
            120.0,
            20.0,
            WHITE,
        );
    }

    pub fn is_solved(&self) -> bool {
        self.solved
    }
}

#[cfg(test)]
mod tests {
    use super::MazePuzzle;

    impl MazePuzzle {
        fn from_grid(grid: Vec<Vec<bool>>, start: (usize, usize), exit: (usize, usize)) -> Self {
            Self {
                width: grid[0].len(),
                height: grid.len(),
                grid,
                player_x: start.0,
                player_y: start.1,
                exit_x: exit.0,
                exit_y: exit.1,
                solved: false,
            }
        }
    }

    #[test]
    fn slide_moves_until_wall_in_one_direction() {
        let puzzle = MazePuzzle::from_grid(
            vec![
                vec![true, true, true, true, true],
                vec![true, false, false, false, true],
                vec![true, true, true, false, true],
                vec![true, true, true, true, true],
            ],
            (1, 1),
            (3, 1),
        );

        assert_eq!(puzzle.slide_destination(1, 1, 1, 0), (3, 1));
    }

    #[test]
    fn slide_stops_immediately_if_wall_is_adjacent() {
        let puzzle = MazePuzzle::from_grid(
            vec![
                vec![true, true, true],
                vec![true, false, true],
                vec![true, true, true],
            ],
            (1, 1),
            (1, 1),
        );

        assert_eq!(puzzle.slide_destination(1, 1, 0, -1), (1, 1));
    }
}
