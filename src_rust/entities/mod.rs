// Модуль для игровых сущностей (игрок, предметы, NPC)

pub struct Player {
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
}

impl Player {
    pub fn new(x: f32, y: f32) -> Self {
        Self {
            x,
            y,
            width: 30.0,
            height: 30.0,
        }
    }
}

pub struct Item {
    pub x: f32,
    pub y: f32,
    pub name: String,
    pub visible: bool,
}

impl Item {
    pub fn new(x: f32, y: f32, name: String) -> Self {
        Self {
            x,
            y,
            name,
            visible: true,
        }
    }
}
