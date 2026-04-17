# Краткое руководство по интеграции ассетов в GameMaker Studio 2

## Быстрый старт

Это руководство поможет быстро интегрировать тематические ассеты пещер в GameMaker Studio 2.

## Шаг 1: Импорт конфигураций

Конфигурационные файлы находятся в:
```
pazzle-game-gamemaker/assets/sprites/cave{N}_{theme}/
```

Каждая пещера имеет:
- `cave{N}_assets_config.json` - основная конфигурация
- `spr_*.txt` - заглушки спрайтов

## Шаг 2: Создание спрайтов

### Для каждого спрайта из конфигурации:

1. **Create > Sprite** в GameMaker Studio 2
2. Назовите согласно `sprite` в конфигурации
3. Установите размер из поля `size` (например, "48x48")
4. Для анимированных:
   - Создайте количество фреймов из `frames`
   - Установите `fps` из конфигурации
5. Настройте Origin:
   - Декорации: Center
   - Платформы: Top Center
   - Эффекты: Center

## Шаг 3: Создание слоев в комнатах

Для каждой пещеры создайте слои согласно `layer` в конфигурации:

### Базовые слои (снизу вверх):
1. `Background` - фоновый спрайт
2. `Decorations_Floor` - декорации на полу
3. `Decorations_Bottom` - нижние элементы
4. `Decorations_Walls` - настенные декорации
5. `Furniture` - мебель и крупные объекты
6. `Decorations_Top` - верхние элементы (сталактиты)
7. `Decorations_Items` - мелкие предметы
8. `Effects_Background` - эффекты заднего плана
9. `Effects_Decorations` - эффекты на декорациях
10. `Effects_Foreground` - эффекты переднего плана
11. `Effects_Particles` - системы частиц

## Шаг 4: Размещение декораций

### По полю `placement`:
- `floor` - на полу комнаты
- `walls` - на стенах
- `ceiling` - на потолке
- `air` - в воздухе (платформы)
- `floor_walls` - на полу и стенах
- `floor_furniture` - на полу и мебели

### По полю `frequency`:
- `common` - часто (каждые 64-128 пикселей)
- `medium` - средне (каждые 128-256 пикселей)
- `rare` - редко (1-3 на комнату)
- `unique` - уникальный (1 на комнату)

## Шаг 5: Настройка освещения

Для объектов с `light_source: true`:

```gml
// В событии Draw объекта
draw_self();

// Добавить свечение
gpu_set_blendmode(bm_add);
draw_set_alpha(0.5);
draw_set_color(light_color); // из конфигурации
draw_circle(x, y, light_radius, false); // radius из конфигурации
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);
```

## Шаг 6: Применение цветовой палитры

Используйте `color_palette` из конфигурации для:
- Фоновых цветов
- Тонирования спрайтов
- UI элементов пещеры

```gml
// Пример применения ambient light
draw_set_color(c_black);
draw_set_alpha(1 - ambient_light); // из lighting в конфигурации
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);
```

## Шаг 7: Добавление эффектов

### Для анимированных эффектов:
1. Создайте объект эффекта
2. В Create Event:
   ```gml
   image_speed = fps / 60; // fps из конфигурации
   image_alpha = alpha; // из конфигурации
   ```
3. Для `blend_mode: "additive"`:
   ```gml
   // В Draw Event
   gpu_set_blendmode(bm_add);
   draw_self();
   gpu_set_blendmode(bm_normal);
   ```

### Для движущихся эффектов:
```gml
// movement: "slow_vertical"
y += 0.5;
if (y > room_height) y = -sprite_height;

// movement: "slow_horizontal"
x += 0.3;
if (x > room_width) x = -sprite_width;
```

## Шаг 8: Интеграция звуков

Добавьте звуки из `ambient_sounds`:
```gml
// В Room Creation Code
audio_play_sound(snd_cave3_gears_turning, 10, true);
audio_sound_gain(snd_cave3_gears_turning, 0.3, 0);
```

## Быстрая проверка

После интеграции проверьте:
- ✓ Все спрайты созданы и названы правильно
- ✓ Слои комнаты соответствуют конфигурации
- ✓ Источники света работают
- ✓ Анимации воспроизводятся с правильным FPS
- ✓ Эффекты используют правильный blend mode
- ✓ Ambient sounds воспроизводятся

## Оптимизация

1. **Sprite batching**: Группируйте одинаковые спрайты на одном слое
2. **Particle systems**: Используйте встроенные системы частиц для эффектов
3. **Lighting**: Ограничьте количество источников света (макс 10-15 на комнату)
4. **Audio**: Используйте audio groups для управления памятью

## Связанные документы

- `docs/cave_assets_3_6_guide.md` - Детальное описание пещер 3-6
- `docs/thematic_assets_guide.md` - Руководство по пещерам 1-2
- `pazzle-game-gamemaker/assets/sprites/` - Конфигурационные файлы

---

**Дата создания**: 17 апреля 2026  
**Версия**: 1.0
