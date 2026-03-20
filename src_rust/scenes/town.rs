use ::rand::{thread_rng, Rng};
use macroquad::prelude::*;

use crate::audio;
use crate::game_state::{GameProgress, GameState, ProgressUpdate};
use crate::ui_text::{draw_game_text, draw_wrapped_game_text, measure_game_text};
use crate::visual_assets::{
    draw_sprite, item_texture, npc_texture, platform_texture, player_texture, Facing,
};

use super::Scene;

struct TownNpc {
    rect: Rect,
    name: &'static str,
    role: &'static str,
    color: Color,
}

struct ActiveDialogue {
    npc_index: usize,
    line_index: usize,
    visible_chars: usize,
    lines: Vec<String>,
}

struct SealMarker {
    level: u8,
    rect: Rect,
    title: &'static str,
    accent: Color,
}

struct MechanicTrainingGame {
    sequence: Vec<KeyCode>,
    reveal_index: usize,
    reveal_timer: f32,
    waiting_for_input: bool,
    input_index: usize,
    round: usize,
    won: bool,
    failed: bool,
}

struct ArchivistQuizGame {
    question_index: usize,
    selected_option: usize,
    score: usize,
    answered: bool,
    passed: bool,
    failed: bool,
}

struct QuizQuestion {
    prompt: &'static str,
    options: [&'static str; 3],
    correct: usize,
}

struct ElderTrialGame {
    secret: i32,
    guess: i32,
    attempts_left: i32,
    resolved: bool,
    won: bool,
    hint: String,
}

enum FocusTarget {
    Entrance,
    Npc(usize),
}

pub struct TownScene {
    progress: GameProgress,
    next_state: Option<GameState>,
    animation_time: f32,
    status_message: String,
    player: Rect,
    entrance_rect: Rect,
    pending_progress_update: Option<ProgressUpdate>,
    npcs: Vec<TownNpc>,
    seals: Vec<SealMarker>,
    active_dialogue: Option<ActiveDialogue>,
    mechanic_training: Option<MechanicTrainingGame>,
    archivist_quiz: Option<ArchivistQuizGame>,
    elder_trial: Option<ElderTrialGame>,
    player_facing: Facing,
}

impl TownScene {
    pub fn new(progress: GameProgress) -> Self {
        Self {
            progress,
            next_state: None,
            animation_time: 0.0,
            status_message: "Подойдите к шахтному спуску и нажмите E. Внутри пещеры уровни идут цепочкой один за другим.".to_string(),
            player: Rect::new(388.0, 474.0, 26.0, 40.0),
            entrance_rect: Rect::new(322.0, 176.0, 156.0, 136.0),
            pending_progress_update: None,
            npcs: vec![
                TownNpc {
                    rect: Rect::new(164.0, 416.0, 26.0, 38.0),
                    name: "Староста Иара",
                    role: "Хранитель тропы",
                    color: Color::from_rgba(226, 188, 126, 255),
                },
                TownNpc {
                    rect: Rect::new(604.0, 414.0, 26.0, 38.0),
                    name: "Механик Роан",
                    role: "Смотритель механизмов",
                    color: Color::from_rgba(146, 208, 255, 255),
                },
                TownNpc {
                    rect: Rect::new(384.0, 376.0, 26.0, 38.0),
                    name: "Архивариус Тель",
                    role: "Толкователь печатей",
                    color: Color::from_rgba(198, 168, 232, 255),
                },
            ],
            seals: vec![
                SealMarker {
                    level: 1,
                    rect: Rect::new(88.0, 128.0, 72.0, 138.0),
                    title: "Лабиринт",
                    accent: Color::from_rgba(130, 212, 255, 255),
                },
                SealMarker {
                    level: 2,
                    rect: Rect::new(186.0, 108.0, 72.0, 158.0),
                    title: "Архив",
                    accent: Color::from_rgba(255, 220, 136, 255),
                },
                SealMarker {
                    level: 3,
                    rect: Rect::new(284.0, 92.0, 72.0, 174.0),
                    title: "Ритм",
                    accent: Color::from_rgba(190, 152, 255, 255),
                },
                SealMarker {
                    level: 4,
                    rect: Rect::new(444.0, 92.0, 72.0, 174.0),
                    title: "Пары",
                    accent: Color::from_rgba(255, 150, 184, 255),
                },
                SealMarker {
                    level: 5,
                    rect: Rect::new(542.0, 108.0, 72.0, 158.0),
                    title: "Разлом",
                    accent: Color::from_rgba(132, 244, 192, 255),
                },
                SealMarker {
                    level: 6,
                    rect: Rect::new(640.0, 128.0, 72.0, 138.0),
                    title: "Ядро",
                    accent: Color::from_rgba(255, 132, 132, 255),
                },
            ],
            active_dialogue: None,
            mechanic_training: None,
            archivist_quiz: None,
            elder_trial: None,
            player_facing: Facing::Down,
        }
    }

    const ARCHIVIST_QUESTIONS: [QuizQuestion; 3] = [
        QuizQuestion {
            prompt: "Какая пещера проверяет героя скольжением до стены?",
            options: ["Лабиринт", "Разлом", "Галерея пар"],
            correct: 0,
        },
        QuizQuestion {
            prompt: "Что действительно открывает следующую пещеру после победы?",
            options: ["Сам факт решения", "Рычаг", "Разговор с NPC"],
            correct: 1,
        },
        QuizQuestion {
            prompt: "Что происходит на второй стадии архивной пещеры?",
            options: ["Платформер", "Финальный таймер", "Игра на память"],
            correct: 2,
        },
    ];

    fn town_entry_level(&self) -> u8 {
        1
    }

    fn current_objective_level(&self) -> u8 {
        self.progress.current_objective_level()
    }

    fn opened_seal_count(&self) -> usize {
        (1..=6)
            .filter(|level| self.progress.is_lever_pulled(*level))
            .count()
    }

    fn level_label(level: u8) -> &'static str {
        match level {
            1 => "лабиринт молчаливых стен",
            2 => "архивную пещеру печатей",
            3 => "грот часовщика",
            4 => "галерею зеркального эха",
            5 => "разлом кристаллов",
            6 => "ядро глубинного хранилища",
            _ => "следующую пещеру",
        }
    }

    fn reward_name(npc_index: usize) -> &'static str {
        match npc_index {
            0 => "Талисман старосты",
            1 => "Ключ механика",
            2 => "Печать архивариуса",
            _ => "награда",
        }
    }

    fn reward_summary(&self, npc_index: usize) -> &'static str {
        match npc_index {
            0 => "30 золота и Талисман старосты",
            1 => "35 золота и Ключ механика",
            2 => "25 золота и Печать архивариуса",
            _ => "награда неизвестна",
        }
    }

    fn npc_activity_completed(&self, npc_index: usize) -> bool {
        match npc_index {
            0 => self.progress.is_elder_trial_completed(),
            1 => self.progress.is_mechanic_training_completed(),
            2 => self.progress.is_archivist_quiz_completed(),
            _ => false,
        }
    }

    fn expedition_stage_label(&self) -> &'static str {
        match self.opened_seal_count() {
            0 => "спуск только начинается",
            1 | 2 => "деревня ещё слушает глубину",
            3 | 4 => "середина маршрута уже вскрыта",
            5 => "до последней печати остался один проход",
            _ => "цепочка печатей закрыта окончательно",
        }
    }

    fn npc_preview(&self, npc_index: usize) -> String {
        let target_level = self.current_objective_level();
        let opened = self.opened_seal_count();

        match npc_index {
            0 => {
                if self.progress.is_expedition_complete()
                    && self.progress.is_elder_trial_completed()
                {
                    "Староста видит завершённую экспедицию и напоминает, что Талисман старосты уже у вас. Испытание можно повторять ради выдержки."
                        .to_string()
                } else if self.progress.is_elder_trial_completed() {
                    format!(
                        "Староста уже признал вашу выдержку и выдал {}. Теперь он следит, как вы дожмёте путь к {}.",
                        Self::reward_name(0),
                        Self::level_label(target_level)
                    )
                } else if opened >= 6 {
                    "Все печати уже открыты. Староста больше говорит не о выживании, а о том, что деревня наконец выдохнула."
                        .to_string()
                } else {
                    format!(
                        "Староста следит за порядком спуска: {}. Сейчас его взгляд направлен в {}.",
                        self.expedition_stage_label(),
                        Self::level_label(target_level)
                    )
                }
            }
            1 => {
                if self.progress.is_expedition_complete()
                    && self.progress.is_mechanic_training_completed()
                {
                    "Роан уже выдал Ключ механика и теперь говорит как мастер после большой смены: можно только шлифовать темп и повторять калибровку."
                        .to_string()
                } else if self.progress.is_mechanic_training_completed() {
                    format!(
                        "Механик уже доверил вам калибровку и выдал {}. Теперь он следит, насколько уверенно вы работаете с рычагами глубже.",
                        Self::reward_name(1)
                    )
                } else if opened == 0 {
                    "Механик объяснит, зачем вообще нужен рычаг после победы, и предложит калибровку на реакцию.".to_string()
                } else {
                    format!(
                        "Механик видит {} уже открытых печатей, сверяет ваш темп со своей калибровкой и всё ещё ждёт, когда вы заберёте {}.",
                        opened,
                        Self::reward_name(1)
                    )
                }
            }
            2 => {
                if self.progress.is_expedition_complete()
                    && self.progress.is_archivist_quiz_completed()
                {
                    "Архивариус уже выдал Печать архивариуса и теперь говорит как летописец завершённого маршрута: можно только перепроверять память и детали."
                        .to_string()
                } else if self.progress.is_archivist_quiz_completed() {
                    format!(
                        "Архивариус уже проверил вашу память и выдал {}. Теперь он комментирует не правила, а нюансы следующей пещеры.",
                        Self::reward_name(2)
                    )
                } else if target_level == 2 {
                    "Архивариус особенно разговорчив перед архивной пещерой и памятью о символах."
                        .to_string()
                } else {
                    format!(
                        "Архивариус читает окружение как документ: сейчас он ждёт, заметите ли вы ритм, ведущий в {}.",
                        Self::level_label(target_level)
                    )
                }
            }
            _ => String::new(),
        }
    }

    fn build_dialogue_lines(&self, npc_index: usize) -> Vec<String> {
        let target_level = self.current_objective_level();
        let opened = self.opened_seal_count();
        let final_open = self.progress.is_lever_pulled(6);

        match npc_index {
            0 => {
                if final_open {
                    let mut lines = vec![
                        "Ты вскрыл все шесть печатей. Для деревни это значит, что Элдорадо больше не висит над пропастью на древних замках.".to_string(),
                        "Теперь мой совет уже не о выживании, а о памяти: не потеряй ощущение пути, который прошёл под нами.".to_string(),
                        "Если снова пойдёшь вниз, смотри на обелиски. Они теперь напоминают не о долге, а о проделанной работе.".to_string(),
                    ];
                    lines.push(
                        if self.progress.is_elder_trial_completed() {
                            "Талисман старосты уже у тебя. Если хочешь ещё раз проверить терпение, подойди и нажми Q: число снова будет скрыто."
                        } else {
                            "Ты закрыл путь под городом, но ещё не прошёл моё личное испытание. Подойди и нажми Q: я всё ещё дам тебе число на поиск."
                        }
                        .to_string(),
                    );
                    lines
                } else {
                    let mut lines = vec![
                        "Слушай внимательно: дальше не набор комнат из меню, а один длинный спуск под деревней.".to_string(),
                        format!(
                            "Сейчас тебе нужно пройти через {}. Пока не сорвёшь печать и не опустишь рычаг, дорога глубже не откроется.",
                            Self::level_label(target_level)
                        ),
                        format!(
                            "Уже вскрыто печатей: {} из 6. Обелиски у шахты показывают это честнее любых слов.",
                            opened
                        ),
                        format!(
                            "Сейчас в деревне состояние простое: {}.",
                            self.expedition_stage_label()
                        ),
                    ];
                    lines.push(
                        if self.progress.is_elder_trial_completed() {
                            "Ты уже прошёл моё испытание на выдержку и получил Талисман старосты. Но если хочешь повторить, подойди и нажми Q."
                        } else {
                            "Перед спуском могу проверить не руки, а голову. Подойди и нажми Q: попробуешь угадать скрытое число за несколько попыток."
                        }
                        .to_string(),
                    );
                    lines.push(
                        if self.progress.is_elder_trial_completed() {
                            "Награда за мою проверку уже твоя, значит теперь я смотрю только на то, выдержишь ли ты оставшийся маршрут."
                        } else {
                            "Моя награда простая: 30 золота и Талисман старосты. Но мне важнее, чтобы ты шёл вниз без суеты."
                        }
                        .to_string(),
                    );
                    lines
                }
            }
            1 => {
                let mut lines = vec![
                    "Я обслуживаю рычаги внизу. Они не для красоты: именно они двигают каменную дверь после победы.".to_string(),
                ];
                if opened == 0 {
                    lines.push("Сначала почувствуй это на первом спуске: решишь печать, а потом сам услышишь, как рычаг сдвигает породу.".to_string());
                } else {
                    lines.push(format!(
                        "У тебя уже открыто {} печатей. Значит, ты видел, как рычаг фиксирует победу и переводит пещеру в пройденное состояние.",
                        opened
                    ));
                }
                lines.push(
                    "Если печать уже ломал раньше, алтарь тебя узнаёт. На повторном заходе в головоломку нажми L, и механизм позволит не тратить время на старое решение."
                        .to_string(),
                );
                lines.push(
                    if self.progress.is_mechanic_training_completed() {
                        "Ты уже забрал Ключ механика и 35 золота. Значит, я буду говорить с тобой уже не как с новичком, а как с человеком, который понимает ритм машины."
                    } else {
                        "Моя тренировка не про сюжет, а про дисциплину. Если пройдёшь её, получишь 35 золота и Ключ механика."
                    }
                    .to_string(),
                );
                if self.progress.is_mechanic_training_completed() {
                    lines.push(
                        "Калибровку ты уже прошёл. Но если хочешь освежить реакцию, подойди ко мне и жми Q: станок снова соберёт схему."
                            .to_string(),
                    );
                } else {
                    lines.push(
                        "Хочешь быстрый тест перед спуском, а не только разговор? Подойди ближе и нажми Q. Я запущу калибровку механизма и посмотрю, держишь ли темп."
                            .to_string(),
                    );
                }
                lines
            }
            2 => {
                let second_level_done = self.progress.is_level_completed(2);
                let mut lines = vec![
                    "Печати любят прятать подсказки в окружении. Смотри не только в центр, но и на свет, стены, руны и движение деталей.".to_string(),
                ];
                if target_level == 2 || !second_level_done {
                    lines.push("Архивная пещера особенно коварна: она проверяет не одну мысль, а две подряд. Сначала слово, потом память о форме.".to_string());
                } else {
                    lines.push(format!(
                        "Раз сейчас на очереди {}, ищи в окружении не просто красоту, а ритм, повтор или напряжение механизма.",
                        Self::level_label(target_level)
                    ));
                }
                lines.push(
                    if self.progress.is_archivist_quiz_completed() {
                        "Печать архивариуса уже у тебя. Значит, дальше я оцениваю не память о правилах, а то, замечаешь ли ты язык самих комнат."
                    } else {
                        "Если хочешь мою печать и 25 золота, придётся доказать, что ты запомнил правила глубин, а не просто наугад двигаешься вперёд."
                    }
                    .to_string(),
                );
                lines.push(
                    "Если видишь, что окно говорит с тобой как тёплая рамка, это житель. Если как тяжёлая каменная плита, это сама печать."
                        .to_string(),
                );
                if self.progress.is_archivist_quiz_completed() {
                    lines.push(
                        "Я уже выдал тебе печать архивариуса. Но если хочешь проверить память ещё раз, подойди и нажми Q."
                            .to_string(),
                    );
                } else {
                    lines.push(
                        "Если хочешь доказать, что помнишь правила глубин, подойди и нажми Q. Я открою короткую викторину хранителя."
                            .to_string(),
                    );
                }
                lines
            }
            _ => vec!["...".to_string()],
        }
    }

    fn player_center(&self) -> Vec2 {
        vec2(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h / 2.0,
        )
    }

    fn focus_target(&self) -> Option<FocusTarget> {
        let center = self.player_center();
        let entrance_center = vec2(
            self.entrance_rect.x + self.entrance_rect.w / 2.0,
            self.entrance_rect.y + self.entrance_rect.h / 2.0,
        );
        let mut best: Option<(f32, FocusTarget)> = None;

        let entrance_distance = center.distance(entrance_center);
        if entrance_distance < 96.0 {
            best = Some((entrance_distance, FocusTarget::Entrance));
        }

        for (index, npc) in self.npcs.iter().enumerate() {
            let npc_center = vec2(npc.rect.x + npc.rect.w / 2.0, npc.rect.y + npc.rect.h / 2.0);
            let distance = center.distance(npc_center);
            if distance < 66.0 {
                if best
                    .as_ref()
                    .map(|(best_dist, _)| distance < *best_dist)
                    .unwrap_or(true)
                {
                    best = Some((distance, FocusTarget::Npc(index)));
                }
            }
        }

        best.map(|(_, target)| target)
    }

    fn start_dialogue(&mut self, npc_index: usize) {
        let lines = self.build_dialogue_lines(npc_index);
        self.active_dialogue = Some(ActiveDialogue {
            npc_index,
            line_index: 0,
            visible_chars: 0,
            lines,
        });
        audio::play_ui_confirm();
        self.status_message =
            "Диалог открыт. E или ENTER - дальше, SPACE - допечатать строку, ESC - закрыть."
                .to_string();
    }

    fn dialogue_line<'a>(&self, dialogue: &'a ActiveDialogue) -> &'a str {
        &dialogue.lines[dialogue.line_index]
    }

    fn finish_or_advance_dialogue(&mut self) {
        let Some(dialogue) = &mut self.active_dialogue else {
            return;
        };

        let total_chars = dialogue.lines[dialogue.line_index].chars().count();

        if dialogue.visible_chars < total_chars {
            dialogue.visible_chars = total_chars;
            audio::play_ui_move();
            return;
        }

        if dialogue.line_index + 1 < dialogue.lines.len() {
            dialogue.line_index += 1;
            dialogue.visible_chars = 0;
            audio::play_ui_move();
        } else {
            self.active_dialogue = None;
            audio::play_ui_cancel();
            self.status_message =
                "Диалог завершён. Подойдите к шахте, чтобы продолжить спуск.".to_string();
        }
    }

    fn visible_dialogue_text(&self) -> Option<String> {
        let dialogue = self.active_dialogue.as_ref()?;
        let line = self.dialogue_line(dialogue);
        Some(line.chars().take(dialogue.visible_chars).collect())
    }

    fn is_mechanic_focused(&self) -> bool {
        matches!(self.focus_target(), Some(FocusTarget::Npc(1)))
    }

    fn is_elder_focused(&self) -> bool {
        matches!(self.focus_target(), Some(FocusTarget::Npc(0)))
    }

    fn is_archivist_focused(&self) -> bool {
        matches!(self.focus_target(), Some(FocusTarget::Npc(2)))
    }

    fn start_mechanic_training(&mut self) {
        self.mechanic_training = Some(MechanicTrainingGame {
            sequence: vec![KeyCode::Up, KeyCode::Right, KeyCode::Left, KeyCode::Down],
            reveal_index: 0,
            reveal_timer: 0.0,
            waiting_for_input: false,
            input_index: 0,
            round: 1,
            won: false,
            failed: false,
        });
        audio::play_ui_confirm();
        self.status_message =
            "Калибровка механика запущена. Смотрите на последовательность и повторяйте её стрелками."
                .to_string();
    }

    fn complete_mechanic_training(&mut self) {
        let first_win = !self.progress.is_mechanic_training_completed();
        self.progress
            .apply_update(ProgressUpdate::MechanicTrainingCompleted);
        if first_win {
            self.pending_progress_update = Some(ProgressUpdate::MechanicTrainingCompleted);
            audio::play_ui_success();
            self.status_message =
                "Калибровка завершена. Роан выдал 35 золота и предмет «Ключ механика».".to_string();
        } else {
            audio::play_ui_confirm();
            self.status_message =
                "Калибровка снова пройдена. Награда уже была получена раньше, но реакция в порядке."
                    .to_string();
        }
    }

    fn mechanic_training_label(key: KeyCode) -> &'static str {
        match key {
            KeyCode::Up => "Вверх",
            KeyCode::Right => "Вправо",
            KeyCode::Down => "Вниз",
            KeyCode::Left => "Влево",
            _ => "?",
        }
    }

    fn mechanic_training_arrow(key: KeyCode) -> &'static str {
        match key {
            KeyCode::Up => "↑",
            KeyCode::Right => "→",
            KeyCode::Down => "↓",
            KeyCode::Left => "←",
            _ => "?",
        }
    }

    fn mechanic_training_color(key: KeyCode) -> Color {
        match key {
            KeyCode::Up => Color::from_rgba(132, 220, 255, 255),
            KeyCode::Right => Color::from_rgba(255, 212, 122, 255),
            KeyCode::Down => Color::from_rgba(132, 242, 182, 255),
            KeyCode::Left => Color::from_rgba(234, 146, 188, 255),
            _ => LIGHTGRAY,
        }
    }

    fn start_elder_trial(&mut self) {
        let mut rng = thread_rng();
        self.elder_trial = Some(ElderTrialGame {
            secret: rng.gen_range(1..=9),
            guess: 5,
            attempts_left: 4,
            resolved: false,
            won: false,
            hint:
                "Староста загадал число от 1 до 9. Меняйте ответ стрелками и подтверждайте Enter."
                    .to_string(),
        });
        audio::play_ui_confirm();
        self.status_message =
            "Испытание старосты началось. Найдите число за ограниченное число попыток.".to_string();
    }

    fn complete_elder_trial(&mut self) {
        let first_win = !self.progress.is_elder_trial_completed();
        self.progress
            .apply_update(ProgressUpdate::ElderTrialCompleted);
        if first_win {
            self.pending_progress_update = Some(ProgressUpdate::ElderTrialCompleted);
            audio::play_ui_success();
            self.status_message =
                "Испытание старосты пройдено. Получено 30 золота и предмет «Талисман старосты»."
                    .to_string();
        } else {
            audio::play_ui_confirm();
            self.status_message =
                "Испытание старосты снова пройдено. Награда уже была получена раньше.".to_string();
        }
    }

    fn start_archivist_quiz(&mut self) {
        self.archivist_quiz = Some(ArchivistQuizGame {
            question_index: 0,
            selected_option: 0,
            score: 0,
            answered: false,
            passed: false,
            failed: false,
        });
        audio::play_ui_confirm();
        self.status_message =
            "Архивариус открыл викторину. Выберите ответ стрелками и подтвердите Enter."
                .to_string();
    }

    fn complete_archivist_quiz(&mut self) {
        let first_win = !self.progress.is_archivist_quiz_completed();
        self.progress
            .apply_update(ProgressUpdate::ArchivistQuizCompleted);
        if first_win {
            self.pending_progress_update = Some(ProgressUpdate::ArchivistQuizCompleted);
            audio::play_ui_success();
            self.status_message =
                "Викторина пройдена. Тель выдал 25 золота и предмет «Печать архивариуса»."
                    .to_string();
        } else {
            audio::play_ui_confirm();
            self.status_message =
                "Викторина снова пройдена. Награда уже была получена, но память у вас крепкая."
                    .to_string();
        }
    }

    fn handle_mechanic_training_input(&mut self) {
        let Some(game) = &mut self.mechanic_training else {
            return;
        };

        if is_key_pressed(KeyCode::Escape) {
            self.mechanic_training = None;
            audio::play_ui_cancel();
            self.status_message =
                "Калибровка остановлена. Если захотите вернуться, подойдите к Роану и нажмите Q."
                    .to_string();
            return;
        }

        if !game.waiting_for_input || game.won || game.failed {
            return;
        }

        for key in [KeyCode::Up, KeyCode::Right, KeyCode::Down, KeyCode::Left] {
            if is_key_pressed(key) {
                audio::play_ui_move();
                if key == game.sequence[game.input_index] {
                    game.input_index += 1;
                    if game.input_index >= game.round {
                        if game.round >= game.sequence.len() {
                            game.won = true;
                            self.complete_mechanic_training();
                        } else {
                            game.round += 1;
                            game.reveal_index = 0;
                            game.reveal_timer = 0.0;
                            game.waiting_for_input = false;
                            game.input_index = 0;
                            self.status_message = format!(
                                "Раунд {} принят. Смотрите следующую последовательность.",
                                game.round - 1
                            );
                        }
                    }
                } else {
                    game.failed = true;
                    audio::play_ui_cancel();
                    self.status_message =
                        "Калибровка сорвалась: ритм рычага ушёл. Нажмите Q у Роана, чтобы начать заново."
                            .to_string();
                }
                break;
            }
        }
    }

    fn handle_archivist_quiz_input(&mut self) {
        let Some(quiz) = &mut self.archivist_quiz else {
            return;
        };

        if is_key_pressed(KeyCode::Escape) {
            self.archivist_quiz = None;
            audio::play_ui_cancel();
            self.status_message =
                "Викторина закрыта. Если захотите вернуться, подойдите к Телю и нажмите Q."
                    .to_string();
            return;
        }

        if quiz.passed || quiz.failed {
            if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
                audio::play_ui_confirm();
                self.archivist_quiz = None;
            }
            return;
        }

        if quiz.answered {
            if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
                audio::play_ui_confirm();
                if quiz.question_index + 1 >= Self::ARCHIVIST_QUESTIONS.len() {
                    if quiz.score >= 2 {
                        quiz.passed = true;
                        self.complete_archivist_quiz();
                    } else {
                        quiz.failed = true;
                        audio::play_ui_cancel();
                        self.status_message =
                            "Тель закрывает фолиант: знаний пока недостаточно. Нажмите Q у архивариуса, чтобы начать заново."
                                .to_string();
                    }
                } else {
                    quiz.question_index += 1;
                    quiz.selected_option = 0;
                    quiz.answered = false;
                    self.status_message = format!(
                        "Вопрос {} из {}. Смотрите формулировку внимательно.",
                        quiz.question_index + 1,
                        Self::ARCHIVIST_QUESTIONS.len()
                    );
                }
            }
            return;
        }

        if is_key_pressed(KeyCode::Up) || is_key_pressed(KeyCode::W) {
            audio::play_ui_move();
            quiz.selected_option = if quiz.selected_option == 0 {
                2
            } else {
                quiz.selected_option - 1
            };
        }

        if is_key_pressed(KeyCode::Down) || is_key_pressed(KeyCode::S) {
            audio::play_ui_move();
            quiz.selected_option = (quiz.selected_option + 1) % 3;
        }

        if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
            audio::play_ui_confirm();
            let question = &Self::ARCHIVIST_QUESTIONS[quiz.question_index];
            if quiz.selected_option == question.correct {
                quiz.score += 1;
                self.status_message =
                    "Ответ принят. Архивариус кивает и открывает следующую карточку.".to_string();
            } else {
                self.status_message =
                    "Ответ неверен. Архивариус отмечает ошибку и всё равно покажет следующий вопрос."
                        .to_string();
            }
            quiz.answered = true;
        }
    }

    fn handle_elder_trial_input(&mut self) {
        let Some(trial) = &mut self.elder_trial else {
            return;
        };

        if is_key_pressed(KeyCode::Escape) {
            self.elder_trial = None;
            audio::play_ui_cancel();
            self.status_message =
                "Испытание старосты закрыто. Если захотите вернуться, подойдите к Иара и нажмите Q."
                    .to_string();
            return;
        }

        if trial.resolved {
            if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
                audio::play_ui_confirm();
                self.elder_trial = None;
            }
            return;
        }

        if is_key_pressed(KeyCode::Up) || is_key_pressed(KeyCode::W) {
            audio::play_ui_move();
            trial.guess = if trial.guess >= 9 { 1 } else { trial.guess + 1 };
        }
        if is_key_pressed(KeyCode::Down) || is_key_pressed(KeyCode::S) {
            audio::play_ui_move();
            trial.guess = if trial.guess <= 1 { 9 } else { trial.guess - 1 };
        }

        if is_key_pressed(KeyCode::Enter) || is_key_pressed(KeyCode::Space) {
            audio::play_ui_confirm();
            trial.attempts_left -= 1;
            if trial.guess == trial.secret {
                trial.resolved = true;
                trial.won = true;
                trial.hint =
                    "Староста кивает: число найдено. Испытание выдержки завершено.".to_string();
                self.complete_elder_trial();
            } else if trial.attempts_left <= 0 {
                trial.resolved = true;
                trial.won = false;
                audio::play_ui_cancel();
                trial.hint = format!(
                    "Попытки закончились. Загаданным числом было {}.",
                    trial.secret
                );
                self.status_message =
                    "Испытание старосты провалено. Нажмите Q у Иара, чтобы начать заново."
                        .to_string();
            } else if trial.guess < trial.secret {
                trial.hint = format!("Слишком мало. Осталось попыток: {}.", trial.attempts_left);
                self.status_message = "Староста советует мыслить смелее: число выше.".to_string();
            } else {
                trial.hint = format!("Слишком много. Осталось попыток: {}.", trial.attempts_left);
                self.status_message = "Староста советует сбросить спешку: число ниже.".to_string();
            }
        }
    }

    fn interact(&mut self) {
        match self.focus_target() {
            Some(FocusTarget::Entrance) => {
                audio::play_ui_confirm();
                self.next_state = Some(GameState::Playing(self.town_entry_level()));
            }
            Some(FocusTarget::Npc(index)) => {
                self.start_dialogue(index);
            }
            None => {
                self.status_message = "Подойдите к спуску или к NPC и нажмите E.".to_string();
            }
        }
    }

    fn draw_background(&self) {
        let platform = platform_texture();
        let relic = item_texture();
        for i in 0..screen_height() as i32 {
            let t = i as f32 / screen_height();
            let color = Color::new(0.01 + t * 0.08, 0.02 + t * 0.10, 0.08 + t * 0.16, 1.0);
            draw_line(0.0, i as f32, screen_width(), i as f32, 1.0, color);
        }

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            168.0,
            Color::from_rgba(0, 0, 0, 66),
        );
        draw_circle(650.0, 92.0, 110.0, Color::from_rgba(220, 56, 88, 24));
        draw_circle(660.0, 94.0, 64.0, Color::from_rgba(255, 224, 144, 38));
        draw_circle(660.0, 94.0, 34.0, Color::from_rgba(255, 224, 144, 160));
        draw_circle(660.0, 94.0, 14.0, Color::from_rgba(255, 240, 198, 255));

        draw_triangle(
            vec2(-30.0, 470.0),
            vec2(190.0, 206.0),
            vec2(420.0, 470.0),
            Color::from_rgba(28, 46, 58, 210),
        );
        draw_triangle(
            vec2(280.0, 470.0),
            vec2(500.0, 164.0),
            vec2(790.0, 470.0),
            Color::from_rgba(22, 36, 48, 220),
        );
        draw_triangle(
            vec2(520.0, 470.0),
            vec2(734.0, 220.0),
            vec2(860.0, 470.0),
            Color::from_rgba(18, 28, 42, 224),
        );
        draw_circle(156.0, 156.0, 60.0, Color::from_rgba(96, 128, 208, 16));
        draw_circle(526.0, 132.0, 52.0, Color::from_rgba(196, 78, 114, 14));

        let ground_y = 470.0;
        draw_rectangle(
            0.0,
            ground_y,
            screen_width(),
            screen_height() - ground_y,
            Color::from_rgba(54, 34, 26, 255),
        );
        draw_rectangle(
            0.0,
            ground_y + 24.0,
            screen_width(),
            54.0,
            Color::from_rgba(90, 66, 48, 255),
        );
        for line in 0..8 {
            let y = ground_y + 8.0 + line as f32 * 10.0;
            draw_rectangle(
                0.0,
                y,
                screen_width(),
                2.0,
                Color::from_rgba(255, 255, 255, 10),
            );
        }

        for idx in 0..5 {
            let x = 24.0 + idx as f32 * 154.0;
            let width = 90.0 + (idx % 2) as f32 * 12.0;
            let height = 88.0 + idx as f32 * 12.0;
            let y = 446.0 - height;
            draw_rectangle(x, y, width, height, Color::from_rgba(24, 28, 48, 236));
            draw_rectangle(
                x + 8.0,
                y + 10.0,
                width - 16.0,
                height - 20.0,
                Color::from_rgba(34, 44, 72, 90),
            );
            draw_triangle(
                vec2(x - 10.0, y),
                vec2(x + width + 10.0, y),
                vec2(x + width / 2.0, y - 38.0),
                Color::from_rgba(74, 32, 30, 245),
            );
            draw_sprite(
                &platform,
                x + 8.0,
                y + height - 24.0,
                48.0,
                24.0,
                WHITE,
            );
        }

        draw_rectangle(
            self.entrance_rect.x - 28.0,
            self.entrance_rect.y + 82.0,
            self.entrance_rect.w + 56.0,
            160.0,
            Color::from_rgba(28, 30, 38, 255),
        );
        draw_triangle(
            vec2(self.entrance_rect.x - 44.0, self.entrance_rect.y + 82.0),
            vec2(
                self.entrance_rect.x + self.entrance_rect.w + 44.0,
                self.entrance_rect.y + 82.0,
            ),
            vec2(
                self.entrance_rect.x + self.entrance_rect.w / 2.0,
                self.entrance_rect.y - 24.0,
            ),
            Color::from_rgba(72, 54, 48, 255),
        );

        let pulse = (self.animation_time * 2.4).sin() * 0.5 + 0.5;
        draw_circle(
            self.entrance_rect.x + self.entrance_rect.w / 2.0,
            self.entrance_rect.y + self.entrance_rect.h / 2.0,
            48.0 + pulse * 24.0,
            Color::from_rgba(92, 210, 255, (18.0 + pulse * 36.0) as u8),
        );
        draw_rectangle(
            self.entrance_rect.x,
            self.entrance_rect.y,
            self.entrance_rect.w,
            self.entrance_rect.h,
            Color::from_rgba(4, 8, 12, 255),
        );
        draw_circle(
            self.entrance_rect.x + self.entrance_rect.w / 2.0,
            self.entrance_rect.y + self.entrance_rect.h / 2.0,
            28.0 + pulse * 18.0,
            Color::from_rgba(122, 216, 255, (36.0 + pulse * 54.0) as u8),
        );
        draw_rectangle_lines(
            self.entrance_rect.x,
            self.entrance_rect.y,
            self.entrance_rect.w,
            self.entrance_rect.h,
            3.0,
            Color::from_rgba(164, 214, 255, 220),
        );
        draw_game_text(
            "DEPTH",
            self.entrance_rect.x + 36.0,
            self.entrance_rect.y - 10.0,
            18.0,
            Color::from_rgba(255, 212, 140, 255),
        );

        for (index, seal) in self.seals.iter().enumerate() {
            let completed = self.progress.is_level_completed(seal.level);
            let opened = self.progress.is_lever_pulled(seal.level);
            let base = if opened {
                Color::from_rgba(182, 210, 118, 255)
            } else if completed {
                Color::from_rgba(248, 210, 126, 255)
            } else {
                Color::from_rgba(84, 92, 112, 255)
            };
            let glow = (self.animation_time * 1.8 + index as f32).sin() * 0.5 + 0.5;
            draw_rectangle(
                seal.rect.x,
                seal.rect.y,
                seal.rect.w,
                seal.rect.h,
                Color::from_rgba(24, 30, 44, 228),
            );
            draw_rectangle_lines(
                seal.rect.x,
                seal.rect.y,
                seal.rect.w,
                seal.rect.h,
                2.0,
                base,
            );
            draw_circle(
                seal.rect.x + seal.rect.w / 2.0,
                seal.rect.y + 30.0,
                8.0 + glow * 4.0,
                Color::new(base.r, base.g, base.b, 0.18 + glow * 0.20),
            );
            draw_circle(
                seal.rect.x + seal.rect.w / 2.0,
                seal.rect.y + 30.0,
                6.0,
                if completed { seal.accent } else { base },
            );
            draw_sprite(
                &relic,
                seal.rect.x + seal.rect.w / 2.0 - 12.0,
                seal.rect.y + 44.0,
                32.0,
                32.0,
                if opened {
                    Color::from_rgba(186, 228, 164, 255)
                } else if completed {
                    Color::from_rgba(255, 236, 166, 255)
                } else {
                    Color::from_rgba(144, 154, 176, 220)
                },
            );
            let title_width = measure_game_text(seal.title, None, 14, 1.0).width;
            draw_game_text(
                seal.title,
                seal.rect.x + seal.rect.w / 2.0 - title_width / 2.0,
                seal.rect.y + seal.rect.h + 18.0,
                14.0,
                Color::from_rgba(220, 226, 236, 255),
            );
        }
        draw_rectangle(
            0.0,
            screen_height() - 154.0,
            screen_width(),
            154.0,
            Color::from_rgba(0, 0, 0, 76),
        );
    }

    fn draw_npc(&self, npc: &TownNpc, is_focused: bool) {
        let bob = (self.animation_time * 2.3 + npc.rect.x * 0.018).sin() * 3.0;
        let y = npc.rect.y + bob;
        let texture = npc_texture();

        draw_ellipse(
            npc.rect.x + npc.rect.w / 2.0,
            y + npc.rect.h + 2.0,
            14.0,
            5.0,
            0.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_sprite(&texture, npc.rect.x - 10.0, y - 6.0, 48.0, 48.0, npc.color);

        if is_focused {
            draw_circle(
                npc.rect.x + npc.rect.w / 2.0,
                y + 9.0,
                20.0,
                Color::from_rgba(255, 214, 126, 30),
            );
            draw_circle_lines(npc.rect.x + npc.rect.w / 2.0, y + 9.0, 15.0, 2.0, WHITE);
            draw_game_text(
                "!",
                npc.rect.x + npc.rect.w / 2.0 - 4.0,
                y - 18.0,
                20.0,
                Color::from_rgba(255, 228, 180, 255),
            );
        }

        draw_game_text(
            npc.name,
            npc.rect.x - 20.0,
            y - 12.0,
            14.0,
            Color::from_rgba(246, 228, 174, 255),
        );
    }

    fn draw_player(&self) {
        let step_bob = (self.animation_time * 8.0).sin().abs() * 2.2;
        let texture = player_texture(self.player_facing);
        draw_circle(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h / 2.0 + 2.0,
            20.0,
            Color::from_rgba(120, 180, 255, 18),
        );
        draw_ellipse(
            self.player.x + self.player.w / 2.0,
            self.player.y + self.player.h + 3.0,
            15.0,
            6.0,
            0.0,
            Color::from_rgba(0, 0, 0, 70),
        );
        draw_sprite(
            &texture,
            self.player.x - 12.0,
            self.player.y - 12.0 - step_bob,
            48.0,
            48.0,
            WHITE,
        );
    }

    fn draw_mechanic_training_overlay(&self) {
        let Some(game) = &self.mechanic_training else {
            return;
        };

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(0, 0, 0, 164),
        );

        let panel = Rect::new(86.0, 112.0, screen_width() - 172.0, 336.0);
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(10, 18, 30, 245),
        );
        draw_rectangle(
            panel.x + 10.0,
            panel.y + 10.0,
            panel.w - 20.0,
            panel.h - 20.0,
            Color::from_rgba(20, 32, 48, 220),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(122, 206, 255, 220),
        );

        draw_game_text(
            "Калибровка механика",
            panel.x + 24.0,
            panel.y + 36.0,
            30.0,
            Color::from_rgba(255, 232, 182, 255),
        );
        let info = if game.won {
            "Станок стабилизирован. Роан подтверждает, что вы держите ритм подземных механизмов."
        } else if game.failed {
            "Последовательность сорвана. В калибровке важен точный порядок нажатий."
        } else if game.waiting_for_input {
            "Теперь повторите последовательность стрелками. Чем дальше раунд, тем длиннее цепочка."
        } else {
            "Сначала наблюдайте за схемой: плитки загорятся по очереди. Запомните порядок."
        };
        draw_wrapped_game_text(
            info,
            panel.x + 24.0,
            panel.y + 66.0,
            panel.w - 48.0,
            18.0,
            4.0,
            Color::from_rgba(214, 224, 238, 255),
        );

        let arrows = [
            (KeyCode::Up, vec2(panel.x + panel.w / 2.0, panel.y + 156.0)),
            (
                KeyCode::Left,
                vec2(panel.x + panel.w / 2.0 - 84.0, panel.y + 230.0),
            ),
            (
                KeyCode::Right,
                vec2(panel.x + panel.w / 2.0 + 84.0, panel.y + 230.0),
            ),
            (
                KeyCode::Down,
                vec2(panel.x + panel.w / 2.0, panel.y + 230.0),
            ),
        ];
        let active_key =
            if !game.waiting_for_input && !game.won && !game.failed && game.reveal_index > 0 {
                Some(game.sequence[game.reveal_index - 1])
            } else {
                None
            };
        for (key, center) in arrows {
            let mut color = Color::from_rgba(40, 56, 76, 255);
            let outline = Self::mechanic_training_color(key);
            if active_key == Some(key) {
                color = Color::new(outline.r, outline.g, outline.b, 0.92);
            }
            draw_circle(center.x, center.y, 34.0, color);
            draw_circle_lines(center.x, center.y, 34.0, 3.0, outline);
            let arrow = Self::mechanic_training_arrow(key);
            let width = measure_game_text(arrow, None, 38, 1.0).width;
            draw_game_text(arrow, center.x - width / 2.0, center.y + 14.0, 38.0, WHITE);
            let label = Self::mechanic_training_label(key);
            let label_width = measure_game_text(label, None, 14, 1.0).width;
            draw_game_text(
                label,
                center.x - label_width / 2.0,
                center.y + 54.0,
                14.0,
                Color::from_rgba(196, 210, 228, 255),
            );
        }

        let status = format!(
            "Раунд: {}/{} | Ввод: {}/{} | Награда: {}",
            game.round,
            game.sequence.len(),
            game.input_index,
            game.round,
            if self.progress.is_mechanic_training_completed() {
                "уже получена"
            } else {
                "35 золота + Ключ механика"
            }
        );
        draw_wrapped_game_text(
            &status,
            panel.x + 24.0,
            panel.y + 286.0,
            panel.w - 48.0,
            16.0,
            4.0,
            Color::from_rgba(132, 214, 255, 255),
        );
        draw_game_text(
            "Стрелки - повторить, ESC - выйти",
            panel.x + 24.0,
            panel.y + panel.h - 18.0,
            17.0,
            Color::from_rgba(255, 210, 122, 255),
        );
    }

    fn draw_archivist_quiz_overlay(&self) {
        let Some(quiz) = &self.archivist_quiz else {
            return;
        };

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(0, 0, 0, 176),
        );

        let panel = Rect::new(92.0, 88.0, screen_width() - 184.0, 374.0);
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(20, 14, 34, 246),
        );
        draw_rectangle(
            panel.x + 10.0,
            panel.y + 10.0,
            panel.w - 20.0,
            panel.h - 20.0,
            Color::from_rgba(34, 22, 52, 228),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(210, 170, 255, 220),
        );

        draw_game_text(
            "Викторина архивариуса",
            panel.x + 24.0,
            panel.y + 34.0,
            30.0,
            Color::from_rgba(246, 226, 255, 255),
        );

        if quiz.passed || quiz.failed {
            let summary = if quiz.passed {
                "Тель доволен: память о правилах глубин подтверждена."
            } else {
                "Тель закрывает фолиант: знаний пока недостаточно для награды."
            };
            draw_wrapped_game_text(
                summary,
                panel.x + 24.0,
                panel.y + 78.0,
                panel.w - 48.0,
                22.0,
                5.0,
                WHITE,
            );
            let result = format!(
                "Верных ответов: {}/{} | Награда: {}",
                quiz.score,
                Self::ARCHIVIST_QUESTIONS.len(),
                if self.progress.is_archivist_quiz_completed() || quiz.passed {
                    "уже получена или выдана"
                } else {
                    "25 золота + Печать архивариуса"
                }
            );
            draw_wrapped_game_text(
                &result,
                panel.x + 24.0,
                panel.y + 158.0,
                panel.w - 48.0,
                18.0,
                4.0,
                Color::from_rgba(192, 212, 236, 255),
            );
            draw_game_text(
                "ENTER / SPACE - закрыть, ESC - выйти",
                panel.x + 24.0,
                panel.y + panel.h - 24.0,
                18.0,
                Color::from_rgba(255, 214, 126, 255),
            );
            return;
        }

        let question = &Self::ARCHIVIST_QUESTIONS[quiz.question_index];
        let header = format!(
            "Вопрос {}/{} | Очки: {}",
            quiz.question_index + 1,
            Self::ARCHIVIST_QUESTIONS.len(),
            quiz.score
        );
        draw_game_text(
            &header,
            panel.x + 24.0,
            panel.y + 62.0,
            18.0,
            Color::from_rgba(132, 214, 255, 255),
        );
        draw_wrapped_game_text(
            question.prompt,
            panel.x + 24.0,
            panel.y + 108.0,
            panel.w - 48.0,
            24.0,
            6.0,
            WHITE,
        );

        for (index, option) in question.options.iter().enumerate() {
            let y = panel.y + 188.0 + index as f32 * 58.0;
            let is_selected = quiz.selected_option == index;
            let is_correct = quiz.answered && question.correct == index;
            let is_wrong_choice = quiz.answered && quiz.selected_option == index && !is_correct;
            let bg = if is_correct {
                Color::from_rgba(56, 108, 78, 220)
            } else if is_wrong_choice {
                Color::from_rgba(120, 52, 66, 220)
            } else if is_selected {
                Color::from_rgba(80, 72, 126, 220)
            } else {
                Color::from_rgba(42, 40, 66, 190)
            };
            draw_rectangle(panel.x + 24.0, y, panel.w - 48.0, 42.0, bg);
            draw_rectangle_lines(
                panel.x + 24.0,
                y,
                panel.w - 48.0,
                42.0,
                2.0,
                if is_selected {
                    Color::from_rgba(220, 198, 255, 255)
                } else {
                    Color::from_rgba(126, 118, 164, 220)
                },
            );
            let label = format!("{}. {}", index + 1, option);
            draw_game_text(
                &label,
                panel.x + 40.0,
                y + 26.0,
                18.0,
                Color::from_rgba(242, 240, 236, 255),
            );
        }

        draw_game_text(
            if quiz.answered {
                "ENTER / SPACE - дальше, ESC - выйти"
            } else {
                "W/S или ↑/↓ - выбор, ENTER - подтвердить, ESC - выйти"
            },
            panel.x + 24.0,
            panel.y + panel.h - 22.0,
            17.0,
            Color::from_rgba(255, 214, 126, 255),
        );
    }

    fn draw_elder_trial_overlay(&self) {
        let Some(trial) = &self.elder_trial else {
            return;
        };

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(0, 0, 0, 172),
        );

        let panel = Rect::new(108.0, 102.0, screen_width() - 216.0, 312.0);
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(32, 22, 18, 246),
        );
        draw_rectangle(
            panel.x + 10.0,
            panel.y + 10.0,
            panel.w - 20.0,
            panel.h - 20.0,
            Color::from_rgba(56, 38, 26, 224),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(240, 196, 126, 220),
        );

        draw_game_text(
            "Испытание старосты",
            panel.x + 24.0,
            panel.y + 34.0,
            30.0,
            Color::from_rgba(255, 230, 184, 255),
        );
        draw_wrapped_game_text(
            "Иара загадал число от 1 до 9. За несколько попыток нужно найти его без суеты и случайного перебора.",
            panel.x + 24.0,
            panel.y + 70.0,
            panel.w - 48.0,
            20.0,
            5.0,
            WHITE,
        );

        let guess_box = Rect::new(panel.x + panel.w / 2.0 - 72.0, panel.y + 132.0, 144.0, 86.0);
        draw_rectangle(
            guess_box.x,
            guess_box.y,
            guess_box.w,
            guess_box.h,
            Color::from_rgba(20, 16, 20, 220),
        );
        draw_rectangle_lines(
            guess_box.x,
            guess_box.y,
            guess_box.w,
            guess_box.h,
            3.0,
            Color::from_rgba(255, 214, 126, 255),
        );
        let guess = format!("{}", trial.guess);
        let width = measure_game_text(&guess, None, 54, 1.0).width;
        draw_game_text(
            &guess,
            guess_box.x + guess_box.w / 2.0 - width / 2.0,
            guess_box.y + 58.0,
            54.0,
            Color::from_rgba(255, 236, 196, 255),
        );

        let stats = format!(
            "Попытки осталось: {} | Награда: {}",
            trial.attempts_left.max(0),
            if self.progress.is_elder_trial_completed() {
                "уже получена"
            } else {
                "30 золота + Талисман старосты"
            }
        );
        draw_wrapped_game_text(
            &stats,
            panel.x + 24.0,
            panel.y + 244.0,
            panel.w - 48.0,
            17.0,
            4.0,
            Color::from_rgba(208, 220, 232, 255),
        );
        draw_wrapped_game_text(
            &trial.hint,
            panel.x + 24.0,
            panel.y + 274.0,
            panel.w - 48.0,
            18.0,
            4.0,
            Color::from_rgba(255, 214, 126, 255),
        );
        draw_game_text(
            if trial.resolved {
                "ENTER / SPACE - закрыть, ESC - выйти"
            } else {
                "W/S или ↑/↓ - изменить число, ENTER - подтвердить, ESC - выйти"
            },
            panel.x + 24.0,
            panel.y + panel.h - 18.0,
            16.0,
            Color::from_rgba(255, 226, 170, 255),
        );
    }

    fn draw_dialogue_overlay(&self) {
        let Some(dialogue) = &self.active_dialogue else {
            return;
        };

        let npc = &self.npcs[dialogue.npc_index];
        let typed_text = self.visible_dialogue_text().unwrap_or_default();
        let panel = Rect::new(58.0, 356.0, screen_width() - 116.0, 172.0);

        draw_rectangle(
            0.0,
            0.0,
            screen_width(),
            screen_height(),
            Color::from_rgba(0, 0, 0, 112),
        );
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(12, 12, 18, 246),
        );
        draw_rectangle(
            panel.x + 8.0,
            panel.y + 8.0,
            panel.w - 16.0,
            panel.h - 16.0,
            Color::from_rgba(48, 18, 22, 118),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(255, 232, 182, 230),
        );
        draw_rectangle(
            panel.x + 20.0,
            panel.y + 72.0,
            panel.w - 40.0,
            3.0,
            Color::from_rgba(255, 222, 144, 48),
        );

        draw_circle(panel.x + 42.0, panel.y + 42.0, 18.0, npc.color);
        draw_circle_lines(
            panel.x + 42.0,
            panel.y + 42.0,
            20.0,
            2.0,
            Color::from_rgba(255, 236, 200, 255),
        );
        draw_game_text(
            npc.name,
            panel.x + 76.0,
            panel.y + 34.0,
            26.0,
            Color::from_rgba(255, 232, 182, 255),
        );
        draw_game_text(
            npc.role,
            panel.x + 76.0,
            panel.y + 58.0,
            16.0,
            Color::from_rgba(210, 220, 235, 255),
        );

        draw_wrapped_game_text(
            &typed_text,
            panel.x + 24.0,
            panel.y + 92.0,
            panel.w - 48.0,
            22.0,
            5.0,
            Color::from_rgba(242, 240, 236, 255),
        );

        let progress = format!(
            "Реплика {}/{}",
            dialogue.line_index + 1,
            dialogue.lines.len()
        );
        draw_game_text(
            &progress,
            panel.x + panel.w - 116.0,
            panel.y + 34.0,
            16.0,
            Color::from_rgba(132, 206, 255, 255),
        );
        draw_game_text(
            "E / ENTER - дальше, SPACE - допечатать, ESC - закрыть",
            panel.x + 24.0,
            panel.y + panel.h - 18.0,
            16.0,
            Color::from_rgba(255, 212, 124, 255),
        );
    }
}

impl Scene for TownScene {
    fn handle_input(&mut self) {
        if self.elder_trial.is_some() {
            self.handle_elder_trial_input();
            return;
        }

        if self.archivist_quiz.is_some() {
            self.handle_archivist_quiz_input();
            return;
        }

        if self.mechanic_training.is_some() {
            self.handle_mechanic_training_input();
            return;
        }

        if self.active_dialogue.is_some() {
            if is_key_pressed(KeyCode::Escape) {
                self.active_dialogue = None;
                audio::play_ui_cancel();
                self.status_message =
                    "Диалог закрыт. Подойдите к шахте, чтобы продолжить спуск.".to_string();
                return;
            }

            if is_key_pressed(KeyCode::Space)
                || is_key_pressed(KeyCode::Enter)
                || is_key_pressed(KeyCode::E)
            {
                self.finish_or_advance_dialogue();
            }
            return;
        }

        if is_key_pressed(KeyCode::E) {
            self.interact();
        }

        if is_key_pressed(KeyCode::Q) && self.is_elder_focused() {
            self.start_elder_trial();
        }
        if is_key_pressed(KeyCode::Q) && self.is_mechanic_focused() {
            self.start_mechanic_training();
        }
        if is_key_pressed(KeyCode::Q) && self.is_archivist_focused() {
            self.start_archivist_quiz();
        }

        if is_key_pressed(KeyCode::Escape) {
            audio::play_ui_cancel();
            self.next_state = Some(GameState::Menu);
        }
    }

    fn update(&mut self) {
        self.animation_time += get_frame_time();

        if self.elder_trial.is_some() {
            return;
        }

        if self.archivist_quiz.is_some() {
            return;
        }

        if let Some(game) = &mut self.mechanic_training {
            if game.won || game.failed {
                return;
            }

            if !game.waiting_for_input {
                game.reveal_timer += get_frame_time();
                if game.reveal_timer >= 0.62 {
                    game.reveal_timer = 0.0;
                    game.reveal_index += 1;
                    if game.reveal_index > game.round {
                        game.waiting_for_input = true;
                        game.reveal_index = 0;
                        self.status_message =
                            format!("Повторите калибровочную схему: {} шаг(а).", game.round);
                    }
                }
            }
            return;
        }

        if let Some(dialogue) = &mut self.active_dialogue {
            let total_chars = dialogue.lines[dialogue.line_index].chars().count();
            if dialogue.visible_chars < total_chars {
                let reveal = (get_frame_time() * 42.0).ceil() as usize;
                dialogue.visible_chars = (dialogue.visible_chars + reveal).min(total_chars);
            }
            return;
        }

        let mut movement = Vec2::ZERO;
        if is_key_down(KeyCode::A) || is_key_down(KeyCode::Left) {
            movement.x -= 1.0;
        }
        if is_key_down(KeyCode::D) || is_key_down(KeyCode::Right) {
            movement.x += 1.0;
        }
        if is_key_down(KeyCode::W) || is_key_down(KeyCode::Up) {
            movement.y -= 1.0;
        }
        if is_key_down(KeyCode::S) || is_key_down(KeyCode::Down) {
            movement.y += 1.0;
        }

        if movement.length_squared() > 0.0 {
            if movement.x.abs() > movement.y.abs() {
                self.player_facing = if movement.x > 0.0 {
                    Facing::Right
                } else {
                    Facing::Left
                };
            } else {
                self.player_facing = if movement.y > 0.0 {
                    Facing::Down
                } else {
                    Facing::Up
                };
            }
            let step = movement.normalize() * 170.0 * get_frame_time();
            self.player.x =
                (self.player.x + step.x).clamp(24.0, screen_width() - self.player.w - 24.0);
            self.player.y =
                (self.player.y + step.y).clamp(120.0, screen_height() - self.player.h - 34.0);
        }
    }

    fn draw(&self) {
        self.draw_background();

        let title = "ДЕРЕВНЯ ЭЛЬДОРАДО";
        let title_width = measure_game_text(title, None, 42, 1.0).width;
        draw_game_text(
            title,
            screen_width() / 2.0 - title_width / 2.0,
            48.0,
            42.0,
            Color::from_rgba(255, 232, 180, 255),
        );
        draw_wrapped_game_text(
            if self.progress.is_expedition_complete() {
                "Подземная цепочка полностью раскрыта. Теперь деревня живёт без печатного замка, а вы можете спускаться повторно ради отдельных испытаний."
            } else {
                "Отсюда начинается один непрерывный спуск. Следующая пещера встречается не в меню, а за открытой дверью внутри предыдущей."
            },
            52.0,
            78.0,
            screen_width() - 104.0,
            18.0,
            4.0,
            Color::from_rgba(192, 208, 226, 255),
        );
        let chapter_label = if self.progress.is_expedition_complete() {
            "CHAPTER // AFTERMATH"
        } else {
            "CHAPTER // TOWN OF ENTRY"
        };
        draw_game_text(
            chapter_label,
            48.0,
            106.0,
            18.0,
            Color::from_rgba(255, 206, 138, 255),
        );

        let objective_panel = Rect::new(44.0, 116.0, screen_width() - 88.0, 74.0);
        draw_rectangle(
            objective_panel.x,
            objective_panel.y,
            objective_panel.w,
            objective_panel.h,
            Color::from_rgba(8, 10, 18, 214),
        );
        draw_rectangle(
            objective_panel.x + 8.0,
            objective_panel.y + 8.0,
            objective_panel.w - 16.0,
            objective_panel.h - 16.0,
            Color::from_rgba(24, 10, 18, 124),
        );
        draw_rectangle_lines(
            objective_panel.x,
            objective_panel.y,
            objective_panel.w,
            objective_panel.h,
            3.0,
            Color::from_rgba(196, 98, 124, 168),
        );
        let objective_text = if self.progress.is_expedition_complete() {
            format!(
                "Экспедиция завершена | Открыто печатей: {}/6 | Решено: {}/6",
                self.opened_seal_count(),
                self.progress.completed_count()
            )
        } else {
            format!(
                "Цель экспедиции: уровень {} | Открыто печатей: {}/6 | Решено: {}/6",
                self.current_objective_level(),
                self.opened_seal_count(),
                self.progress.completed_count()
            )
        };
        draw_wrapped_game_text(
            &objective_text,
            objective_panel.x + 16.0,
            objective_panel.y + 24.0,
            objective_panel.w - 32.0,
            17.0,
            3.0,
            Color::from_rgba(224, 232, 240, 255),
        );
        let inventory_text = format!(
            "Золото: {} | Предметы: {} | Иара: {} | Роан: {} | Тель: {}",
            self.progress.gold,
            self.progress.item_count(),
            if self.progress.is_elder_trial_completed() {
                "испытание пройдено"
            } else {
                "испытание не пройдено"
            },
            if self.progress.is_mechanic_training_completed() {
                "пройдена"
            } else {
                "не пройдена"
            },
            if self.progress.is_archivist_quiz_completed() {
                "викторина пройдена"
            } else {
                "викторина не пройдена"
            }
        );
        draw_wrapped_game_text(
            &inventory_text,
            objective_panel.x + 16.0,
            objective_panel.y + 50.0,
            objective_panel.w - 32.0,
            15.0,
            3.0,
            Color::from_rgba(156, 198, 236, 255),
        );

        for npc in &self.npcs {
            let focused = matches!(self.focus_target(), Some(FocusTarget::Npc(index)) if self.npcs[index].name == npc.name);
            self.draw_npc(npc, focused);
        }

        self.draw_player();

        let focus = self.focus_target();
        let panel = Rect::new(486.0, 286.0, 290.0, 188.0);
        draw_rectangle(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            Color::from_rgba(10, 12, 18, 244),
        );
        draw_rectangle(
            panel.x + 8.0,
            panel.y + 8.0,
            panel.w - 16.0,
            panel.h - 16.0,
            Color::from_rgba(42, 18, 22, 92),
        );
        draw_rectangle_lines(
            panel.x,
            panel.y,
            panel.w,
            panel.h,
            3.0,
            Color::from_rgba(255, 224, 164, 214),
        );
        draw_game_text(
            "FOCUS",
            panel.x + 18.0,
            panel.y + 18.0,
            16.0,
            Color::from_rgba(255, 204, 126, 255),
        );

        match focus {
            Some(FocusTarget::Entrance) => {
                let target_level = self.current_objective_level();
                let relic = item_texture();
                draw_game_text(
                    "Шахтный спуск",
                    panel.x + 18.0,
                    panel.y + 42.0,
                    24.0,
                    Color::from_rgba(132, 220, 255, 255),
                );
                draw_sprite(
                    &relic,
                    panel.x + panel.w - 64.0,
                    panel.y + 18.0,
                    32.0,
                    32.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    "Шахта всегда начинается с первой пещеры, а дальше путь идёт цепочкой через внутренние двери.",
                    panel.x + 18.0,
                    panel.y + 74.0,
                    panel.w - 36.0,
                    18.0,
                    4.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    &format!(
                        "Текущая цель по прогрессу: уровень {}. Если ранние пещеры уже решены, внутри можно быстро открыть их рычаги заново и пройти дальше.",
                        target_level
                    ),
                    panel.x + 18.0,
                    panel.y + 110.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    LIGHTGRAY,
                );
                draw_game_text(
                    "E - спуститься",
                    panel.x + 18.0,
                    panel.y + 154.0,
                    16.0,
                    Color::from_rgba(255, 214, 126, 255),
                );
            }
            Some(FocusTarget::Npc(index)) => {
                let npc = &self.npcs[index];
                draw_game_text(npc.name, panel.x + 18.0, panel.y + 42.0, 24.0, npc.color);
                draw_game_text(
                    npc.role,
                    panel.x + 18.0,
                    panel.y + 68.0,
                    16.0,
                    Color::from_rgba(210, 220, 235, 255),
                );
                draw_wrapped_game_text(
                    &self.npc_preview(index),
                    panel.x + 18.0,
                    panel.y + 96.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    LIGHTGRAY,
                );
                draw_game_text(
                    if self.npc_activity_completed(index) {
                        "Награда уже получена"
                    } else {
                        "Награда ещё не получена"
                    },
                    panel.x + 18.0,
                    panel.y + 134.0,
                    15.0,
                    if self.npc_activity_completed(index) {
                        Color::from_rgba(158, 238, 176, 255)
                    } else {
                        Color::from_rgba(255, 204, 126, 255)
                    },
                );
                draw_wrapped_game_text(
                    self.reward_summary(index),
                    panel.x + 18.0,
                    panel.y + 150.0,
                    panel.w - 36.0,
                    14.0,
                    3.0,
                    Color::from_rgba(180, 198, 218, 255),
                );
                draw_game_text(
                    if index == 0 {
                        "E - говорить, Q - испытание"
                    } else if index == 1 {
                        "E - говорить, Q - калибровка"
                    } else if index == 2 {
                        "E - говорить, Q - викторина"
                    } else {
                        "E - говорить"
                    },
                    panel.x + 18.0,
                    panel.y + 172.0,
                    14.0,
                    Color::from_rgba(255, 214, 126, 255),
                );
            }
            None => {
                draw_game_text(
                    "Площадь перед шахтой",
                    panel.x + 18.0,
                    panel.y + 42.0,
                    24.0,
                    Color::from_rgba(255, 228, 180, 255),
                );
                draw_wrapped_game_text(
                    "Подойдите к шахтному спуску, чтобы продолжить цепочку пещер, или поговорите с жителями за подсказками.",
                    panel.x + 18.0,
                    panel.y + 74.0,
                    panel.w - 36.0,
                    18.0,
                    4.0,
                    WHITE,
                );
                draw_wrapped_game_text(
                    "WASD/стрелки - движение. E - взаимодействие. ESC - меню.",
                    panel.x + 18.0,
                    panel.y + 130.0,
                    panel.w - 36.0,
                    16.0,
                    4.0,
                    Color::from_rgba(120, 210, 255, 255),
                );
            }
        }

        draw_rectangle(
            22.0,
            520.0,
            screen_width() - 44.0,
            54.0,
            Color::from_rgba(8, 12, 20, 205),
        );
        draw_rectangle_lines(
            22.0,
            520.0,
            screen_width() - 44.0,
            54.0,
            2.0,
            Color::from_rgba(98, 152, 208, 120),
        );
        draw_wrapped_game_text(
            &self.status_message,
            38.0,
            542.0,
            screen_width() - 76.0,
            18.0,
            3.0,
            Color::from_rgba(220, 228, 238, 255),
        );

        self.draw_dialogue_overlay();
        self.draw_elder_trial_overlay();
        self.draw_mechanic_training_overlay();
        self.draw_archivist_quiz_overlay();
    }

    fn get_next_state(&self) -> Option<GameState> {
        self.next_state
    }

    fn take_progress_update(&mut self) -> Option<ProgressUpdate> {
        self.pending_progress_update.take()
    }
}
