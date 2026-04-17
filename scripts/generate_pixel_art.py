#!/usr/bin/env python3
"""
Генератор пиксельной графики в стиле Deltarune
Создаёт детальные спрайты с выразительными глазами и контурами
"""

from PIL import Image, ImageDraw

# Палитра цветов в стиле Deltarune
COLORS = {
    'skin': (255, 220, 180),
    'skin_shadow': (200, 170, 130),
    'skin_highlight': (255, 240, 210),
    'hair_brown': (101, 67, 33),
    'hair_dark': (60, 40, 20),
    'hair_light': (139, 95, 63),
    'hair_white': (220, 220, 220),
    'shirt_blue': (70, 130, 180),
    'shirt_dark': (50, 100, 140),
    'shirt_light': (100, 160, 210),
    'pants_gray': (105, 105, 105),
    'pants_dark': (70, 70, 70),
    'pants_light': (130, 130, 130),
    'boots_black': (30, 30, 30),
    'boots_dark': (10, 10, 10),
    'boots_light': (50, 50, 50),
    'eye_white': (255, 255, 255),
    'eye_pupil': (20, 20, 20),
    'eye_highlight': (255, 255, 255),
    'outline': (20, 20, 20),
    'npc_roan_clothes': (139, 69, 19),  # Коричневый
    'npc_roan_clothes_dark': (101, 45, 14),
    'npc_roan_clothes_light': (160, 82, 45),
    'npc_roan_hat': (101, 67, 33),
    'npc_tellah_robe': (75, 0, 130),  # Индиго
    'npc_tellah_robe_dark': (50, 0, 90),
    'npc_tellah_robe_light': (106, 38, 173),
    'npc_tellah_glasses': (192, 192, 192),
    'npc_yore_clothes': (128, 0, 128),  # Пурпурный
    'npc_yore_clothes_dark': (90, 0, 90),
    'npc_yore_clothes_light': (160, 32, 240),
    'npc_yore_staff': (139, 69, 19),
    'npc_yore_staff_dark': (101, 45, 14),
    'npc_yore_staff_light': (160, 82, 45),
}

def create_pixel_art(size=64):
    """Создаёт детальный спрайт игрока в стиле Deltarune"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    scale = size / 64
    
    # Тело
    draw.rectangle([int(center - 8*scale), int(center + 8*scale), int(center + 8*scale), int(center + 24*scale)],
                   fill=COLORS['pants_gray'], outline=COLORS['outline'], width=int(2*scale))
    
    # Рубашка
    draw.rectangle([int(center - 10*scale), int(center - 8*scale), int(center + 10*scale), int(center + 12*scale)],
                   fill=COLORS['shirt_blue'], outline=COLORS['outline'], width=int(2*scale))
    
    # Голова
    draw.ellipse([int(center - 10*scale), int(center - 20*scale), int(center + 10*scale), int(center)],
                 fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Волосы
    draw.arc([int(center - 12*scale), int(center - 24*scale), int(center + 12*scale), int(center - 4*scale)],
             0, 180, fill=COLORS['hair_brown'], width=int(4*scale))
    
    # Глаза
    eye_y = int(center - 8*scale)
    eye_spacing = int(4*scale)
    
    # Левый глаз
    draw.ellipse([int(center - 6*scale - eye_spacing), int(eye_y - 2*scale),
                  int(center - 2*scale - eye_spacing), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center - 5*scale - eye_spacing), int(eye_y + 1*scale),
                  int(center - 3*scale - eye_spacing), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    draw.ellipse([int(center - 5*scale - eye_spacing), int(eye_y + 1*scale),
                  int(center - 4*scale - eye_spacing), int(eye_y + 2*scale)],
                 fill=COLORS['eye_highlight'])
    
    # Правый глаз
    draw.ellipse([int(center + 2*scale + eye_spacing), int(eye_y - 2*scale),
                  int(center + 6*scale + eye_spacing), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center + 3*scale + eye_spacing), int(eye_y + 1*scale),
                  int(center + 5*scale + eye_spacing), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    draw.ellipse([int(center + 3*scale + eye_spacing), int(eye_y + 1*scale),
                  int(center + 4*scale + eye_spacing), int(eye_y + 2*scale)],
                 fill=COLORS['eye_highlight'])
    
    # Руки
    draw.rectangle([int(center - 16*scale), int(center - 4*scale), int(center - 10*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 10*scale), int(center - 4*scale), int(center + 16*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Ноги
    draw.rectangle([int(center - 8*scale), int(center + 24*scale), int(center - 4*scale), int(center + 32*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 4*scale), int(center + 24*scale), int(center + 8*scale), int(center + 32*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    
    return img

def create_npc_roan(size=64):
    """Создаёт спрайт механика Роана"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    scale = size / 64
    
    # Тело
    draw.rectangle([int(center - 10*scale), int(center + 10*scale), int(center + 10*scale), int(center + 28*scale)],
                   fill=COLORS['npc_roan_clothes'], outline=COLORS['outline'], width=int(2*scale))
    
    # Голова
    draw.ellipse([int(center - 12*scale), int(center - 22*scale), int(center + 12*scale), int(center)],
                 fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Волосы (короткие)
    draw.arc([int(center - 14*scale), int(center - 26*scale), int(center + 14*scale), int(center - 6*scale)],
             0, 180, fill=COLORS['hair_brown'], width=int(4*scale))
    
    # Глаза
    eye_y = int(center - 8*scale)
    draw.ellipse([int(center - 6*scale), int(eye_y - 2*scale), int(center - 2*scale), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center - 5*scale), int(eye_y + 1*scale), int(center - 3*scale), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    draw.ellipse([int(center + 2*scale), int(eye_y - 2*scale), int(center + 6*scale), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center + 3*scale), int(eye_y + 1*scale), int(center + 5*scale), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    
    # Руки
    draw.rectangle([int(center - 14*scale), int(center - 4*scale), int(center - 8*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 8*scale), int(center - 4*scale), int(center + 14*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Ноги
    draw.rectangle([int(center - 10*scale), int(center + 28*scale), int(center - 6*scale), int(center + 36*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 6*scale), int(center + 28*scale), int(center + 10*scale), int(center + 36*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    
    # Кепка
    draw.rectangle([int(center - 12*scale), int(center - 26*scale), int(center + 12*scale), int(center - 22*scale)],
                   fill=COLORS['npc_roan_hat'], outline=COLORS['outline'], width=int(1*scale))
    
    return img

def create_npc_tellah(size=64):
    """Создаёт спрайт архивариуса Теля"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    scale = size / 64
    
    # Тело (robe)
    draw.rectangle([int(center - 11*scale), int(center + 8*scale), int(center + 11*scale), int(center + 30*scale)],
                   fill=COLORS['npc_tellah_robe'], outline=COLORS['outline'], width=int(2*scale))
    
    # Голова
    draw.ellipse([int(center - 13*scale), int(center - 24*scale), int(center + 13*scale), int(center)],
                 fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Борода
    draw.ellipse([int(center - 10*scale), int(center - 2*scale), int(center + 10*scale), int(center + 12*scale)],
                 fill=COLORS['hair_light'], outline=COLORS['outline'], width=int(1*scale))
    
    # Глаза
    eye_y = int(center - 10*scale)
    draw.ellipse([int(center - 7*scale), int(eye_y - 2*scale), int(center - 3*scale), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center - 6*scale), int(eye_y + 1*scale), int(center - 4*scale), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    draw.ellipse([int(center + 3*scale), int(eye_y - 2*scale), int(center + 7*scale), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center + 4*scale), int(eye_y + 1*scale), int(center + 6*scale), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    
    # Очки
    draw.rectangle([int(center - 7*scale), int(eye_y - 1*scale), int(center - 3*scale), int(eye_y + 3*scale)],
                   fill=COLORS['npc_tellah_glasses'], outline=COLORS['outline'], width=int(1*scale))
    draw.rectangle([int(center + 3*scale), int(eye_y - 1*scale), int(center + 7*scale), int(eye_y + 3*scale)],
                   fill=COLORS['npc_tellah_glasses'], outline=COLORS['outline'], width=int(1*scale))
    draw.line([int(center - 3*scale), int(eye_y), int(center + 3*scale), int(eye_y)],
              fill=COLORS['npc_tellah_glasses'], width=int(1*scale))
    
    # Руки
    draw.rectangle([int(center - 15*scale), int(center - 4*scale), int(center - 9*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 9*scale), int(center - 4*scale), int(center + 15*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Ноги
    draw.rectangle([int(center - 11*scale), int(center + 30*scale), int(center - 7*scale), int(center + 38*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 7*scale), int(center + 30*scale), int(center + 11*scale), int(center + 38*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    
    return img

def create_npc_yore(size=64):
    """Создаёт спрайт старосты Иара"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size // 2
    scale = size / 64
    
    # Тело
    draw.rectangle([int(center - 10*scale), int(center + 10*scale), int(center + 10*scale), int(center + 28*scale)],
                   fill=COLORS['npc_yore_clothes'], outline=COLORS['outline'], width=int(2*scale))
    
    # Голова
    draw.ellipse([int(center - 12*scale), int(center - 22*scale), int(center + 12*scale), int(center)],
                 fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Волосы (седые)
    draw.arc([int(center - 14*scale), int(center - 26*scale), int(center + 14*scale), int(center - 6*scale)],
             0, 180, fill=COLORS['hair_white'], width=int(4*scale))
    
    # Глаза
    eye_y = int(center - 8*scale)
    draw.ellipse([int(center - 6*scale), int(eye_y - 2*scale), int(center - 2*scale), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center - 5*scale), int(eye_y + 1*scale), int(center - 3*scale), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    draw.ellipse([int(center + 2*scale), int(eye_y - 2*scale), int(center + 6*scale), int(eye_y + 4*scale)],
                 fill=COLORS['eye_white'], outline=COLORS['outline'], width=int(1*scale))
    draw.ellipse([int(center + 3*scale), int(eye_y + 1*scale), int(center + 5*scale), int(eye_y + 3*scale)],
                 fill=COLORS['eye_pupil'])
    
    # Руки
    draw.rectangle([int(center - 14*scale), int(center - 4*scale), int(center - 8*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 8*scale), int(center - 4*scale), int(center + 14*scale), int(center + 8*scale)],
                   fill=COLORS['skin'], outline=COLORS['outline'], width=int(2*scale))
    
    # Ноги
    draw.rectangle([int(center - 10*scale), int(center + 28*scale), int(center - 6*scale), int(center + 36*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    draw.rectangle([int(center + 6*scale), int(center + 28*scale), int(center + 10*scale), int(center + 36*scale)],
                   fill=COLORS['boots_black'], outline=COLORS['outline'], width=int(2*scale))
    
    # Посох
    draw.rectangle([int(center - 16*scale), int(center - 16*scale), int(center - 14*scale), int(center + 16*scale)],
                   fill=COLORS['npc_yore_staff'], outline=COLORS['outline'], width=int(1*scale))
    draw.rectangle([int(center - 16*scale), int(center - 16*scale), int(center - 12*scale), int(center - 12*scale)],
                   fill=COLORS['npc_yore_staff_light'])
    
    return img

def main():
    print("Генерация пиксельной графики в стиле Deltarune...")
    
    # Генерируем спрайты игрока
    print("Создаём спрайт игрока...")
    player = create_pixel_art(64)
    player.save('assets/sprites/player_down.png')
    print("✓ player_down.png")
    
    # Создаём зеркальные отражения для других направлений
    player_left = player.transpose(Image.FLIP_LEFT_RIGHT)
    player_left.save('assets/sprites/player_left.png')
    print("✓ player_left.png")
    
    player_right = player_left.transpose(Image.FLIP_LEFT_RIGHT)
    player_right.save('assets/sprites/player_right.png')
    print("✓ player_right.png")
    
    player_up = player.transpose(Image.FLIP_TOP_BOTTOM)
    player_up.save('assets/sprites/player_up.png')
    print("✓ player_up.png")
    
    # Генерируем спрайты NPC
    print("Создаём спрайт механика Роана...")
    npc_roan = create_npc_roan(64)
    npc_roan.save('assets/sprites/npc_roan.png')
    print("✓ npc_roan.png")
    
    print("Создаём спрайт архивариуса Теля...")
    npc_tellah = create_npc_tellah(64)
    npc_tellah.save('assets/sprites/npc_tellah.png')
    print("✓ npc_tellah.png")
    
    print("Создаём спрайт старосты Иара...")
    npc_yore = create_npc_yore(64)
    npc_yore.save('assets/sprites/npc_yore.png')
    print("✓ npc_yore.png")
    
    print("\nГенерация завершена! Все спрайты сохранены в assets/sprites/")

if __name__ == '__main__':
    main()
