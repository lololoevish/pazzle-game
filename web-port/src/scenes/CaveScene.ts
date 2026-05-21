import Phaser from "phaser";
import {
	GAME_HEIGHT,
	GAME_WIDTH,
	LEVEL_COUNT,
	PLAYER_CONFIG,
	PUZZLE_TYPES,
	type PuzzleType,
} from "../game/constants";
import { completeLevel } from "../game/GameState";
import { loadProgress, saveProgress } from "../game/SaveSystem";
import { addHelp, addPanel, addTitle } from "../systems/UiSystem";

type CaveData = {
	level?: number;
};

type Interactable = {
	name: string;
	object: Phaser.GameObjects.GameObject;
	action: () => void;
};

type AutoZone = {
	zone: Phaser.GameObjects.Zone;
	action: () => void;
	triggered: boolean;
};

type WordCell = {
	x: number;
	y: number;
	letter: string;
	rect: Phaser.GameObjects.Rectangle;
};

type MemoryCard = {
	index: number;
	symbol: string;
	rect: Phaser.GameObjects.Rectangle;
	label: Phaser.GameObjects.Text;
	revealed: boolean;
	matched: boolean;
};

type CaveTheme = {
	bgColor: string;
	panelFill: number;
	wallFill: number;
	wallStroke: number;
	accent: number;
	labelColor: string;
	name: string;
};

const CAVE_THEMES: readonly CaveTheme[] = [
	// 0: Лабиринт — глубокий индиго/фиолетовый
	{
		name: "exploration_echo",
		bgColor: "#1e1b4b",
		panelFill: 0x2e2669,
		wallFill: 0x0f172a,
		wallStroke: 0x475569,
		accent: 0x8b5cf6,
		labelColor: "#c4b5fd",
	},
	// 1: Поиск слов — тёмный океанский синий
	{
		name: "ancient_archive",
		bgColor: "#0c1635",
		panelFill: 0x1e3a5f,
		wallFill: 0x0a1628,
		wallStroke: 0x1e40af,
		accent: 0x3b82f6,
		labelColor: "#93c5fd",
	},
	// 2: Ритм — тёмный багряный
	{
		name: "clockwork_mechanism",
		bgColor: "#1a0505",
		panelFill: 0x450a0a,
		wallFill: 0x180404,
		wallStroke: 0x991b1b,
		accent: 0xef4444,
		labelColor: "#fca5a5",
	},
	// 3: Memory Match — тёмный изумруд
	{
		name: "mirror_reflection",
		bgColor: "#041a1a",
		panelFill: 0x064e3b,
		wallFill: 0x022c22,
		wallStroke: 0x065f46,
		accent: 0x10b981,
		labelColor: "#6ee7b7",
	},
	// 4: Платформер — тёмный янтарь
	{
		name: "crystal_cavern",
		bgColor: "#1a0c00",
		panelFill: 0x451a03,
		wallFill: 0x1c0a00,
		wallStroke: 0x7c2d12,
		accent: 0xf59e0b,
		labelColor: "#fde68a",
	},
];

const CAVE_BOUNDS = { x: 56, y: 112, width: 688, height: 420 };
const MAZE_CELL_SIZE = 24;
const MAZE_START_X = 220;
const MAZE_START_Y = 154;
const MAZE_START_COL = 0;
const MAZE_START_ROW = 13;
const MAZE_GOAL_COL = 13;
const MAZE_GOAL_ROW = 13;

const MAZE_GRID_1 = [
	"111111111111111",
	"100010000000001",
	"101010111011101",
	"101000100010001",
	"101110101110101",
	"100000101000101",
	"111011101011101",
	"100010001000001",
	"101110111110101",
	"100000000010001",
	"101111101011101",
	"100000101000101",
	"101110101110101",
	"000010000000001",
	"111111111111111",
] as const;

const MAZE_GRID_2 = [
	"111111111111111",
	"100000001000001",
	"101111101011101",
	"101000100010101",
	"101010111110101",
	"100010000000001",
	"111011111011101",
	"100000001010001",
	"101111101010101",
	"101000001000101",
	"101011111110101",
	"100010000010101",
	"111010111010101",
	"000000100000001",
	"111111111111111",
] as const;

const MAZE_GRID_3 = [
	"111111111111111",
	"100010000010001",
	"101010111010101",
	"101000001000101",
	"101111101111101",
	"100000100000101",
	"111110111110101",
	"100000000010001",
	"101111111011101",
	"100010000000101",
	"101010111110101",
	"101010100010001",
	"101011101011101",
	"000000001000001",
	"111111111111111",
] as const;

export class CaveScene extends Phaser.Scene {
	private level = 1;
	private solved = false;
	private statusText?: Phaser.GameObjects.Text;
	private player?: Phaser.Physics.Arcade.Sprite;
	private cursors?: Phaser.Types.Input.Keyboard.CursorKeys;
	private wasd?: Record<string, Phaser.Input.Keyboard.Key>;
	private interactKey?: Phaser.Input.Keyboard.Key;
	private spaceKey?: Phaser.Input.Keyboard.Key;
	private escKey?: Phaser.Input.Keyboard.Key;
	private shiftKey?: Phaser.Input.Keyboard.Key;
	private numberKeys: Phaser.Input.Keyboard.Key[] = [];
	private solids?: Phaser.Physics.Arcade.StaticGroup;
	private lever?: Phaser.Physics.Arcade.Sprite;
	private readonly interactables: Interactable[] = [];
	private readonly autoZones: AutoZone[] = [];
	private readonly wordCells: WordCell[] = [];
	private isDashing = false;
	private dashCooldown = 0;
	private jumpCount = 0;
	private mathQuestion = "";
	private mathAnswer = 0;
	private mathOptions: number[] = [];
	private soundTrapCorrectSequence: number[] = [];
	private readonly foundWords = new Set<string>();
	private wordStart?: WordCell;
	private rhythmSequence: number[] = [];
	private rhythmRound = 1;
	private rhythmInputIndex = 0;
	private rhythmShowing = false;
	private readonly rhythmButtons: (
		| Phaser.GameObjects.Rectangle
		| Phaser.GameObjects.Sprite
	)[] = [];
	private readonly memoryCards: MemoryCard[] = [];
	private firstMemoryCard?: MemoryCard;
	private memoryLocked = false;
	private crystalCount = 0;
	private theme: CaveTheme = CAVE_THEMES[0];
	private mazeCol = MAZE_START_COL;
	private mazeRow = MAZE_START_ROW;
	private mazeMoveLocked = false;
	private currentMoveX = 0;
	private currentMoveY = 0;
	private coyoteTimer = 0;
	private jumpBufferTimer = 0;
	private riddleIndex = 0;
	private soundTrapSequence: number[] = [];
	private soundTrapInputIndex = 0;
	private songSequence: number[] = [];
	private songInputIndex = 0;
	private jumpingSafeIndex = 0;
	private finalNextRune = 1;
	private riddleAnswers: string[] = [];
	private jumpingPath: number[] = [];
	private focusRing?: Phaser.GameObjects.Arc;
	private activeMazeGrid: string[] = [];
	private wordSearchWords: string[] = [];
	private riddlesList: { question: string; answer: string }[] = [];
	private ticTacToeBoard: ("X" | "O" | "")[] = Array(9).fill("") as (
		| "X"
		| "O"
		| ""
	)[];
	private readonly ticTacToeRects: Phaser.GameObjects.Rectangle[] = [];
	private readonly ticTacToeLabels: Phaser.GameObjects.Text[] = [];
	private ticTacToeLocked = false;

	public constructor() {
		super("CaveScene");
	}

	public init(data: CaveData): void {
		this.level = Math.min(
			LEVEL_COUNT,
			Math.max(1, Number(data.level) || loadProgress().currentLevel),
		);
		this.solved = false;
		this.isDashing = false;
		this.dashCooldown = 0;
		this.jumpCount = 0;
		this.statusText = undefined;
		this.player = undefined;
		this.cursors = undefined;
		this.wasd = undefined;
		this.interactKey = undefined;
		this.spaceKey = undefined;
		this.escKey = undefined;
		this.shiftKey = undefined;
		this.numberKeys = [];
		this.solids = undefined;
		this.lever = undefined;
		this.focusRing = undefined;
		this.interactables.length = 0;
		this.autoZones.length = 0;
		this.wordCells.length = 0;
		this.foundWords.clear();
		this.wordStart = undefined;
		this.rhythmSequence = [];
		this.rhythmRound = 1;
		this.rhythmInputIndex = 0;
		this.rhythmShowing = false;
		this.rhythmButtons.length = 0;
		this.memoryCards.length = 0;
		this.firstMemoryCard = undefined;
		this.memoryLocked = false;
		this.mazeCol = MAZE_START_COL;
		this.mazeRow = MAZE_START_ROW;
		this.mazeMoveLocked = false;
		this.selectionLine = undefined;
		this.crystalCount = 0;
		this.currentMoveX = 0;
		this.currentMoveY = 0;
		this.coyoteTimer = 0;
		this.jumpBufferTimer = 0;
		this.riddleIndex = 0;
		this.theme = CAVE_THEMES[(this.level - 1) % CAVE_THEMES.length];

		// Выбор одного из трех лабиринтов
		const mazeVariants = [MAZE_GRID_1, MAZE_GRID_2, MAZE_GRID_3];
		this.activeMazeGrid = [...mazeVariants[(this.level - 1) % 3]];

		// Генерация случайной последовательности нот
		const rawSoundSeq: number[] = [];
		while (rawSoundSeq.length < 5) {
			const randomNote = Phaser.Math.Between(0, 6);
			if (!rawSoundSeq.includes(randomNote)) {
				rawSoundSeq.push(randomNote);
			}
		}
		this.soundTrapSequence = [...rawSoundSeq];
		this.soundTrapCorrectSequence = [...rawSoundSeq].sort((a, b) => a - b);

		// Генерация случайных дорожек
		this.jumpingPath = Array.from({ length: 5 }, () =>
			Phaser.Math.Between(0, 2),
		);
		this.songSequence = this.shuffle([0, 1, 2, 3, 4]);

		// Выбор слов для поиска
		const wordSearchWordsPool = [
			["ЛАБИРИНТ", "ПАЗЗЛ", "ПЕЩЕРА", "ГОРОД"],
			["КРИСТАЛЛ", "ЗОЛОТО", "ПОРТАЛ", "ГЕРОЙ"],
			["ЗАГАДКА", "ПОБЕДА", "РЫЧАГ", "КАМЕНЬ"],
		];
		this.wordSearchWords = wordSearchWordsPool[(this.level - 1) % 3];

		// Выбор случайных трех загадок из пула
		const ALL_RIDDLES = [
			{ question: "Что выше леса, но легче пера?", answer: "ДЫМ" },
			{ question: "Что всегда идёт, но никогда не приходит?", answer: "ВРЕМЯ" },
			{ question: "Что имеет лицо, но не может видеть?", answer: "МОНЕТА" },
			{ question: "Без рук, без ног, а рисовать умеет?", answer: "МОРОЗ" },
			{ question: "Зимой греет, весной тлеет, летом умирает?", answer: "СНЕГ" },
			{
				question: "Что можно разбить, даже не прикоснувшись к нему?",
				answer: "ОБЕЩАНИЕ",
			},
			{ question: "Не лает, не кусает, а в дом не пускает?", answer: "ЗАМОК" },
			{
				question:
					"Сидит дед, во сто шуб одет, кто его раздевает, тот слезы проливает?",
				answer: "ЛУК",
			},
		];
		const shuffledRiddles = this.shuffle(ALL_RIDDLES);
		this.riddlesList = shuffledRiddles.slice(0, 3);
		this.riddleAnswers = this.riddlesList.map((r) => r.answer);

		// Инициализация Магической арифметики
		const num1 = Phaser.Math.Between(3, 12);
		const num2 = Phaser.Math.Between(2, 9);
		const operation = Phaser.Math.Between(0, 2); // 0: +, 1: -, 2: *
		if (operation === 0) {
			this.mathQuestion = `${num1} + ${num2} = ?`;
			this.mathAnswer = num1 + num2;
		} else if (operation === 1) {
			this.mathQuestion = `${num1 + num2} - ? = ${num1}`;
			this.mathAnswer = num2;
		} else {
			this.mathQuestion = `? * ${num2} = ${num1 * num2}`;
			this.mathAnswer = num1;
		}
		const wrong1 = this.mathAnswer + Phaser.Math.Between(1, 3);
		const wrong2 = Math.max(1, this.mathAnswer - Phaser.Math.Between(1, 3));
		this.mathOptions = this.shuffle([this.mathAnswer, wrong1, wrong2]);
		this.ticTacToeBoard = Array(9).fill("") as ("X" | "O" | "")[];
		this.ticTacToeRects.length = 0;
		this.ticTacToeLabels.length = 0;
		this.ticTacToeLocked = false;
	}

	public create(): void {
		this.cameras.main.setBackgroundColor(this.theme.bgColor);
		this.add
			.image(GAME_WIDTH / 2, GAME_HEIGHT / 2, "caveBackground")
			.setAlpha(0.4)
			.setTint(this.theme.panelFill);
		this.add
			.tileSprite(
				GAME_WIDTH / 2,
				GAME_HEIGHT / 2,
				GAME_WIDTH,
				GAME_HEIGHT,
				"tileFloor",
			)
			.setAlpha(0.2)
			.setTint(this.theme.wallFill);

		this.physics.world.setBounds(
			CAVE_BOUNDS.x,
			CAVE_BOUNDS.y,
			CAVE_BOUNDS.width,
			CAVE_BOUNDS.height,
		);
		this.solids = this.physics.add.staticGroup();

		addTitle(this, `Пещера ${this.level}`, 34);
		this.add
			.text(400, 68, this.getPuzzleName(), {
				fontFamily: "Arial",
				fontSize: "20px",
				color: this.theme.labelColor,
			})
			.setOrigin(0.5);

		// Основная панель пещеры
		if ("nineslice" in this.add) {
			(this.add as any)
				.nineslice(400, 315, "uiPanel", undefined, 710, 410, 20, 20, 20, 20)
				.setAlpha(0.6);
		} else {
			addPanel(this, 400, 315, 710, 410);
		}

		this.add.text(92, 120, this.getPuzzlePrompt(), {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#f8fafc",
			wordWrap: { width: 616 },
			lineSpacing: 5,
		});
		this.statusText = this.add.text(92, 468, "", {
			fontFamily: "Arial",
			fontSize: "17px",
			color: "#fde68a",
			wordWrap: { width: 616 },
		});
		this.focusRing = this.add
			.circle(0, 0, 36)
			.setStrokeStyle(3, 0xfde68a, 0.95)
			.setDepth(80)
			.setVisible(false);

		this.createRoomCollision();
		this.createAutoExit();
		this.createSceneDecorations();
		this.createPuzzle();
		this.createLever();
		this.createAtmosphere();

		const playerStart = this.getPlayerStartPosition();
		this.player = this.physics.add
			.sprite(playerStart.x, playerStart.y, "player")
			.setCollideWorldBounds(true);
		if (this.getPuzzleType() === "maze") {
			this.player.setDisplaySize(16, 16).setDepth(20);
			this.player.setCircle(7, 1, 1);
		} else {
			this.player.setDisplaySize(36, 44).setDepth(20);
		}
		if (this.solids && this.getPuzzleType() !== "maze") {
			this.physics.add.collider(this.player, this.solids);
		}

		for (const autoZone of this.autoZones) {
			this.physics.add.overlap(this.player, autoZone.zone, () =>
				this.triggerAutoZone(autoZone),
			);
		}

		this.refreshStatus(
			"Герой больше не проходит сквозь стены. Для выхода просто зайди в проход слева.",
		);
		addHelp(
			this,
			this.getPuzzleType() === "maze"
				? "Лабиринт: стрелки — точное движение, WASD — скольжение до стены, Esc — хаб."
				: "WASD/стрелки — движение, Shift — ускорение, E/Space/цифры — действие, Esc — хаб. Проходы работают автоматически.",
		);

		this.cursors = this.input.keyboard?.createCursorKeys();
		this.wasd = this.input.keyboard?.addKeys("W,A,S,D") as Record<
			string,
			Phaser.Input.Keyboard.Key
		>;
		this.interactKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.E,
		);
		this.spaceKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.SPACE,
		);
		this.escKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.ESC,
		);
		this.shiftKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.SHIFT,
		);
		this.numberKeys = [
			Phaser.Input.Keyboard.KeyCodes.ONE,
			Phaser.Input.Keyboard.KeyCodes.TWO,
			Phaser.Input.Keyboard.KeyCodes.THREE,
			Phaser.Input.Keyboard.KeyCodes.FOUR,
			Phaser.Input.Keyboard.KeyCodes.FIVE,
			Phaser.Input.Keyboard.KeyCodes.SIX,
			Phaser.Input.Keyboard.KeyCodes.SEVEN,
			Phaser.Input.Keyboard.KeyCodes.EIGHT,
			Phaser.Input.Keyboard.KeyCodes.NINE,
		]
			.map((code) => this.input.keyboard?.addKey(code))
			.filter(Boolean) as Phaser.Input.Keyboard.Key[];
	}

	public update(_time: number, delta: number): void {
		if (!this.player || !this.cursors || !this.wasd) {
			return;
		}

		if (this.dashCooldown > 0) {
			this.dashCooldown -= delta;
		}

		const dt = Math.min(delta / 1000, 0.05);

		const isPlatformer = this.getPuzzleType() === "platformer";

		if (isPlatformer) {
			this.updatePlatformerMovement(dt);
		} else if (!this.solved && this.getPuzzleType() === "maze") {
			this.updateMazeMovement();
		} else {
			const left = this.cursors.left.isDown || this.wasd.A.isDown;
			const right = this.cursors.right.isDown || this.wasd.D.isDown;
			const up = this.cursors.up.isDown || this.wasd.W.isDown;
			const down = this.cursors.down.isDown || this.wasd.S.isDown;
			const inputX = Number(right) - Number(left);
			const inputY = Number(down) - Number(up);
			const accel = PLAYER_CONFIG.topdownAcceleration * dt;
			const decel = PLAYER_CONFIG.topdownDeceleration * dt;
			this.currentMoveX = this.approach(
				this.currentMoveX,
				inputX,
				inputX === 0 ? decel : accel,
			);
			this.currentMoveY = this.approach(
				this.currentMoveY,
				inputY,
				inputY === 0 ? decel : accel,
			);
			const diagonal = this.currentMoveX !== 0 && this.currentMoveY !== 0;
			const speed = diagonal
				? PLAYER_CONFIG.topdownDiagonalSpeed
				: PLAYER_CONFIG.topdownSpeed;
			const sprint = this.shiftKey?.isDown ? PLAYER_CONFIG.sprintMultiplier : 1;

			// Запуск рывка (Space)
			const pressedSpace = this.spaceKey
				? Phaser.Input.Keyboard.JustDown(this.spaceKey)
				: false;
			const isMoving = inputX !== 0 || inputY !== 0;

			if (
				pressedSpace &&
				!this.isDashing &&
				this.dashCooldown <= 0 &&
				isMoving
			) {
				this.isDashing = true;
				this.dashCooldown = 600; // Кулдаун 0.6 сек
				this.cameras.main.shake(100, 0.003);

				this.tweens.add({
					targets: this.player,
					duration: 150,
					onUpdate: () => {
						if (!this.player) return;
						this.spawnGhostTrail(this.player.x, this.player.y);
						this.spawnStepParticle(this.player.x, this.player.y);
					},
					onComplete: () => {
						this.isDashing = false;
					},
				});
			}

			let velocityX = this.currentMoveX * speed * sprint;
			let velocityY = this.currentMoveY * speed * sprint;
			if (this.isDashing) {
				velocityX *= 3.2;
				velocityY *= 3.2;
			}

			this.player.setVelocity(velocityX, velocityY);

			// Мягкий Squash & Stretch для анимации ГГ
			if (isMoving && !this.isDashing) {
				const time = this.time.now;
				const stretchX = 1 + Math.sin(time / 80) * 0.08;
				const stretchY = 1 - Math.sin(time / 80) * 0.08;
				this.player.setScale(stretchX, stretchY);

				// Наклон
				const angle = velocityX * 0.03;
				this.player.setAngle(angle);

				// Пылинки
				if (this.time.now % 6 === 0) {
					this.spawnStepParticle(this.player.x, this.player.y);
				}
			} else if (!this.isDashing) {
				// Дыхание стоя стоя
				const time = this.time.now;
				const breath = 1 + Math.sin(time / 300) * 0.02;
				this.player.setScale(1, breath);
				this.player.setAngle(0);
			}
		}
		this.updateInteractableFocus();

		const pressedInteract = this.interactKey
			? Phaser.Input.Keyboard.JustDown(this.interactKey)
			: false;

		if (pressedInteract) {
			this.interact();
		}
		this.handleNumberInput();

		if (this.escKey && Phaser.Input.Keyboard.JustDown(this.escKey)) {
			this.scene.start("TownScene");
		}

		this.updateWordSearchLine();
	}

	private getPlayerStartPosition(): { x: number; y: number } {
		if (this.getPuzzleType() === "maze") {
			return this.getMazeCellCenter(MAZE_START_COL, MAZE_START_ROW);
		}

		return { x: 140, y: 468 };
	}

	private updatePlatformerMovement(dt: number): void {
		if (!this.player || !this.cursors || !this.wasd) return;

		const body = this.player.body as Phaser.Physics.Arcade.Body | undefined;
		const left = this.cursors.left.isDown || this.wasd.A.isDown;
		const right = this.cursors.right.isDown || this.wasd.D.isDown;
		const jumpPressed =
			Phaser.Input.Keyboard.JustDown(this.cursors.up) ||
			Phaser.Input.Keyboard.JustDown(this.wasd.W) ||
			(this.spaceKey && Phaser.Input.Keyboard.JustDown(this.spaceKey));
		const jumpDown =
			this.cursors.up.isDown ||
			this.wasd.W.isDown ||
			Boolean(this.spaceKey?.isDown);
		const jumpReleased =
			Phaser.Input.Keyboard.JustUp(this.cursors.up) ||
			Phaser.Input.Keyboard.JustUp(this.wasd.W) ||
			Boolean(this.spaceKey && Phaser.Input.Keyboard.JustUp(this.spaceKey));
		const onGround = Boolean(body?.blocked.down || body?.touching.down);

		if (onGround) {
			this.jumpCount = 0;
			this.coyoteTimer = PLAYER_CONFIG.coyoteTime;
		} else {
			this.coyoteTimer = Math.max(0, this.coyoteTimer - dt);
		}

		if (jumpPressed) {
			this.jumpBufferTimer = PLAYER_CONFIG.jumpBufferTime;
		} else {
			this.jumpBufferTimer = Math.max(0, this.jumpBufferTimer - dt);
		}

		const inputX = Number(right) - Number(left);
		const sprint = this.shiftKey?.isDown ? PLAYER_CONFIG.sprintMultiplier : 1;
		const targetVelocity = inputX * PLAYER_CONFIG.platformerMoveSpeed * sprint;
		const accel = onGround
			? PLAYER_CONFIG.platformerGroundAcceleration
			: PLAYER_CONFIG.platformerAirAcceleration;
		const decel = onGround
			? PLAYER_CONFIG.platformerGroundDeceleration
			: PLAYER_CONFIG.platformerAirDeceleration;
		const nextVelocityX = this.approach(
			this.player.body?.velocity.x ?? 0,
			targetVelocity,
			(inputX === 0 ? decel : accel) * dt,
		);

		this.player.setVelocityX(nextVelocityX);

		// Механика обычного прыжка
		if (this.jumpBufferTimer > 0 && (onGround || this.coyoteTimer > 0)) {
			this.player.setVelocityY(-PLAYER_CONFIG.jumpSpeed);
			this.jumpBufferTimer = 0;
			this.coyoteTimer = 0;
			this.jumpCount = 1;
			this.player.setScale(0.8, 1.25); // Растяжение при прыжке
			this.spawnStepParticle(this.player.x, this.player.y);
		}
		// Двойной прыжок в воздухе!
		else if (jumpPressed && !onGround && this.jumpCount < 2) {
			this.player.setVelocityY(-PLAYER_CONFIG.jumpSpeed * 0.9);
			this.jumpBufferTimer = 0;
			this.jumpCount = 2;
			this.player.setScale(1.25, 0.75); // Сжатие при двойном прыжке
			this.cameras.main.shake(85, 0.003);
			for (let i = 0; i < 6; i++) {
				this.spawnStepParticle(this.player.x, this.player.y);
			}
		}

		if (
			jumpReleased &&
			(this.player.body?.velocity.y ?? 0) < -PLAYER_CONFIG.jumpCutSpeed
		) {
			this.player.setVelocityY(-PLAYER_CONFIG.jumpCutSpeed);
		}

		const gravity =
			(this.player.body?.velocity.y ?? 0) < 0
				? jumpDown
					? PLAYER_CONFIG.gravityRiseHold
					: PLAYER_CONFIG.gravityRiseRelease
				: PLAYER_CONFIG.gravityFall;
		this.player.setGravityY(gravity);

		// Визуальные покачивания в платформере
		if (onGround) {
			if (inputX !== 0) {
				const time = this.time.now;
				this.player.setScale(
					1 + Math.sin(time / 70) * 0.07,
					1 - Math.sin(time / 70) * 0.07,
				);
				this.player.setAngle(nextVelocityX * 0.035);
				if (this.time.now % 6 === 0) {
					this.spawnStepParticle(this.player.x, this.player.y);
				}
			} else {
				// Плавное возвращение к норме с дыханием
				const time = this.time.now;
				this.player.setScale(1, 1 + Math.sin(time / 300) * 0.02);
				this.player.setAngle(0);
			}
		} else {
			// В воздухе наклоняемся по направлению полета
			this.player.setAngle(nextVelocityX * 0.045);
		}

		// Если упали слишком низко
		if (this.player.y > 560) {
			this.player.setPosition(140, 468);
			this.player.setVelocity(0, 0);
			this.refreshStatus("Ты упал в бездну! Попробуй еще раз.");
		}
	}

	private updateMazeMovement(): void {
		if (!this.player || !this.cursors || !this.wasd) return;
		this.player.setVelocity(0, 0);

		if (this.mazeMoveLocked) {
			return;
		}

		const slideLeft = this.wasd.A.isDown;
		const slideRight = this.wasd.D.isDown;
		const slideUp = this.wasd.W.isDown;
		const slideDown = this.wasd.S.isDown;

		if (slideLeft || slideRight || slideUp || slideDown) {
			const direction = {
				x: Number(slideRight) - Number(slideLeft),
				y: Number(slideDown) - Number(slideUp),
			};
			// Приоритет горизонтали если нажато по диагонали (для простоты как в GML)
			if (direction.x !== 0) direction.y = 0;
			this.slideMazeMarker(direction.x, direction.y);
		} else {
			const stepLeft = Phaser.Input.Keyboard.JustDown(this.cursors.left);
			const stepRight = Phaser.Input.Keyboard.JustDown(this.cursors.right);
			const stepUp = Phaser.Input.Keyboard.JustDown(this.cursors.up);
			const stepDown = Phaser.Input.Keyboard.JustDown(this.cursors.down);

			if (stepLeft || stepRight || stepUp || stepDown) {
				const direction = {
					x: Number(stepRight) - Number(stepLeft),
					y: Number(stepDown) - Number(stepUp),
				};
				if (direction.x !== 0) direction.y = 0;
				this.moveMazeMarker(direction.x, direction.y);
			}
		}
	}

	private moveMazeMarker(dx: number, dy: number): void {
		if (!this.player || (dx === 0 && dy === 0)) return;

		const nextCol = this.mazeCol + dx;
		const nextRow = this.mazeRow + dy;
		if (!this.isMazeOpen(nextCol, nextRow)) {
			this.refreshStatus("Там стена. Стрелками двигайся по открытым клеткам.");
			return;
		}

		this.setMazeMarkerCell(nextCol, nextRow, 90);
	}

	private slideMazeMarker(dx: number, dy: number): void {
		if (!this.player || (dx === 0 && dy === 0)) return;

		let targetCol = this.mazeCol;
		let targetRow = this.mazeRow;
		while (this.isMazeOpen(targetCol + dx, targetRow + dy)) {
			targetCol += dx;
			targetRow += dy;
		}

		if (targetCol === this.mazeCol && targetRow === this.mazeRow) {
			this.refreshStatus("Скольжение заблокировано стеной рядом.");
			return;
		}

		const distance =
			Math.abs(targetCol - this.mazeCol) + Math.abs(targetRow - this.mazeRow);
		this.setMazeMarkerCell(targetCol, targetRow, 90 + distance * 55);
	}

	private setMazeMarkerCell(col: number, row: number, duration: number): void {
		if (!this.player) return;

		this.mazeCol = col;
		this.mazeRow = row;
		this.mazeMoveLocked = true;
		const target = this.getMazeCellCenter(col, row);
		this.tweens.add({
			targets: this.player,
			x: target.x,
			y: target.y,
			duration,
			ease: "Sine.easeInOut",
			onComplete: () => {
				this.mazeMoveLocked = false;
				if (col === MAZE_GOAL_COL && row === MAZE_GOAL_ROW) {
					this.markSolved(
						"Лабиринт пройден. Теперь подойди к рычагу и нажми E/Space.",
					);
				}
			},
		});
	}

	private getMazeCellCenter(
		col: number,
		row: number,
	): { x: number; y: number } {
		return {
			x: MAZE_START_X + col * MAZE_CELL_SIZE,
			y: MAZE_START_Y + row * MAZE_CELL_SIZE,
		};
	}

	private isMazeOpen(col: number, row: number): boolean {
		return this.activeMazeGrid[row]?.[col] === "0";
	}

	private selectionLine?: Phaser.GameObjects.Graphics;

	private updateWordSearchLine(): void {
		if (!this.wordStart || !this.player) {
			this.selectionLine?.clear();
			return;
		}

		if (!this.selectionLine) {
			this.selectionLine = this.add.graphics().setDepth(15);
		}

		this.selectionLine.clear();
		this.selectionLine.lineStyle(4, 0x93c5fd, 0.5);
		this.selectionLine.lineBetween(
			this.wordStart.rect.x,
			this.wordStart.rect.y,
			this.player.x,
			this.player.y,
		);
	}

	private createRoomCollision(): void {
		this.add
			.rectangle(
				400,
				322,
				CAVE_BOUNDS.width,
				CAVE_BOUNDS.height,
				this.theme.panelFill,
				0.45,
			)
			.setStrokeStyle(2, this.theme.accent);
		this.createWall(400, 105, 710, 18);
		this.createWall(400, 548, 710, 18);
		this.createWall(52, 326, 18, 420);
		this.createWall(748, 326, 18, 420);
	}

	private createWall(
		x: number,
		y: number,
		width: number,
		height: number,
	): void {
		const wallVisual = this.add
			.tileSprite(x, y, width, height, "caveWall")
			.setTint(this.theme.wallFill)
			.setAlpha(0.96)
			.setDepth(2);
		this.add
			.rectangle(x, y, width, height, 0x000000, 0)
			.setStrokeStyle(1, this.theme.wallStroke, 0.65)
			.setDepth(wallVisual.depth + 1);

		// Важно: физику держим на Rectangle, а не на TileSprite.
		// После визуального апгрейда TileSprite-стены могли давать нестабильные Arcade-body,
		// из-за чего пазлы с лабиринтом/платформами переставали нормально работать.
		const wallBody = this.add.rectangle(x, y, width, height, 0x000000, 0);
		this.physics.add.existing(wallBody, true);
		this.solids?.add(wallBody);
	}

	private createSceneDecorations(): void {
		for (const item of [
			{ x: 150, y: 475, scale: 0.65, tint: 0xfb7185 },
			{ x: 675, y: 475, scale: 0.55, tint: 0xc084fc },
			{ x: 610, y: 276, scale: 0.44, tint: 0x67e8f9 },
		]) {
			const mushroom = this.add
				.sprite(item.x, item.y, "glowMushroom")
				.setTint(item.tint)
				.setScale(item.scale)
				.setAlpha(0.72)
				.setDepth(4);

			this.tweens.add({
				targets: mushroom,
				alpha: 1,
				scale: item.scale * 1.08,
				duration: Phaser.Math.Between(900, 1500),
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});
		}

		for (const item of [
			{ x: 248, y: 118, scale: 0.52 },
			{ x: 560, y: 118, scale: 0.46 },
			{ x: 508, y: 535, scale: 0.5 },
		]) {
			this.add
				.sprite(item.x, item.y, "caveCrystalCluster")
				.setTint(this.theme.accent)
				.setScale(item.scale)
				.setAlpha(0.55)
				.setDepth(4);
		}

		for (const item of [
			{ x: 135, y: 114, scale: 0.55 },
			{ x: 330, y: 116, scale: 0.42 },
			{ x: 660, y: 114, scale: 0.5 },
		]) {
			this.add
				.sprite(item.x, item.y, "stalactite")
				.setTint(this.theme.wallStroke)
				.setScale(item.scale)
				.setAlpha(0.62)
				.setDepth(4);
		}

		const type = this.getPuzzleType();
		const thematicSprite =
			type === "rhythm" || type === "sound_trap" || type === "cave_song"
				? "gearEmblem"
				: type === "pairs" || type === "memory_advanced"
					? "mirrorShard"
					: "runeStone";
		for (const item of [
			{ x: 118, y: 292, scale: 0.6 },
			{ x: 680, y: 292, scale: 0.6 },
		]) {
			this.add
				.sprite(item.x, item.y, thematicSprite)
				.setTint(this.theme.accent)
				.setScale(item.scale)
				.setAlpha(0.55)
				.setDepth(3);
		}

		for (const item of [
			{ x: 112, y: 206, scale: 0.68 },
			{ x: 705, y: 212, scale: 0.72 },
			{ x: 248, y: 402, scale: 0.55 },
		]) {
			this.add
				.sprite(item.x, item.y, "caveVine")
				.setTint(this.theme.accent)
				.setScale(item.scale)
				.setAlpha(0.42)
				.setDepth(3);
		}

		for (const item of [
			{ x: 400, y: 322, scale: 3.8, alpha: 0.06 },
			{ x: 700, y: 468, scale: 1.05, alpha: 0.2 },
		]) {
			const circle = this.add
				.sprite(item.x, item.y, "magicCircle")
				.setTint(this.theme.accent)
				.setScale(item.scale)
				.setAlpha(item.alpha)
				.setDepth(1);

			this.tweens.add({
				targets: circle,
				angle: 360,
				duration: 22000,
				repeat: -1,
			});
		}

		const pebbles = [
			{ x: 150, y: 430, scale: 0.7 },
			{ x: 258, y: 150, scale: 0.55 },
			{ x: 560, y: 490, scale: 0.65 },
			{ x: 710, y: 284, scale: 0.5 },
		];
		for (const item of pebbles) {
			this.add
				.sprite(item.x, item.y, "stonePebble")
				.setTint(this.theme.wallStroke)
				.setScale(item.scale)
				.setAlpha(0.45)
				.setDepth(3);
		}

		for (const item of [
			{ x: 118, y: 142, scale: 0.9 },
			{ x: 705, y: 142, scale: 0.9 },
		]) {
			this.add
				.sprite(item.x, item.y, "torchGlow")
				.setTint(this.theme.accent)
				.setScale(item.scale)
				.setAlpha(0.38)
				.setDepth(3);
		}

		for (let i = 0; i < 8; i++) {
			const sparkle = this.add
				.sprite(
					Phaser.Math.Between(
						CAVE_BOUNDS.x + 50,
						CAVE_BOUNDS.x + CAVE_BOUNDS.width - 50,
					),
					Phaser.Math.Between(
						CAVE_BOUNDS.y + 30,
						CAVE_BOUNDS.y + CAVE_BOUNDS.height - 30,
					),
					"starSparkle",
				)
				.setTint(this.theme.accent)
				.setAlpha(0.2)
				.setScale(Phaser.Math.FloatBetween(0.35, 0.7))
				.setDepth(4);

			this.tweens.add({
				targets: sparkle,
				alpha: 0.55,
				scale: sparkle.scale * 1.25,
				duration: Phaser.Math.Between(900, 1800),
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});
		}
	}

	private createAutoExit(): void {
		this.add
			.rectangle(72, 468, 24, 86, 0x14532d, 0.7)
			.setStrokeStyle(2, 0x86efac);
		this.add
			.text(90, 518, "Выход", {
				fontFamily: "Arial",
				fontSize: "14px",
				color: "#dcfce7",
			})
			.setOrigin(0.5);
		const exitZone = this.add.zone(72, 468, 28, 92);
		this.physics.add.existing(exitZone, true);
		this.autoZones.push({
			zone: exitZone,
			action: () => this.scene.start("TownScene"),
			triggered: false,
		});
	}

	private createAtmosphere(): void {
		this.add
			.tileSprite(400, 320, 730, 260, "mist")
			.setAlpha(0.28)
			.setTint(this.theme.accent)
			.setDepth(1);

		for (const rune of [
			{ x: 160, y: 150, scale: 0.52 },
			{ x: 690, y: 170, scale: 0.46 },
			{ x: 650, y: 470, scale: 0.38 },
		]) {
			this.add
				.sprite(rune.x, rune.y, "runeGlow")
				.setTint(this.theme.accent)
				.setScale(rune.scale)
				.setAlpha(0.55)
				.setDepth(3);
		}

		// Виньетка
		const vignette = this.add.graphics().setDepth(100).setScrollFactor(0);
		vignette.fillGradientStyle(
			0x000000,
			0x000000,
			0x000000,
			0x000000,
			0,
			0,
			0.4,
			0.4,
		);
		vignette.fillRect(0, 0, GAME_WIDTH, GAME_HEIGHT);

		// Летающие частицы (пыль/магия)
		for (let i = 0; i < 20; i++) {
			const x = Phaser.Math.Between(
				CAVE_BOUNDS.x,
				CAVE_BOUNDS.x + CAVE_BOUNDS.width,
			);
			const y = Phaser.Math.Between(
				CAVE_BOUNDS.y,
				CAVE_BOUNDS.y + CAVE_BOUNDS.height,
			);
			const dot = this.add.circle(x, y, 1, 0xffffff, 0.3).setDepth(5);

			this.tweens.add({
				targets: dot,
				x: x + Phaser.Math.Between(-20, 20),
				y: y + Phaser.Math.Between(-20, 20),
				alpha: 0.1,
				duration: Phaser.Math.Between(2000, 5000),
				yoyo: true,
				repeat: -1,
			});
		}
	}

	private createLever(): void {
		this.add
			.sprite(700, 468, "runeGlow")
			.setTint(this.theme.accent)
			.setScale(0.7)
			.setAlpha(0.4)
			.setDepth(3);

		this.lever = this.physics.add
			.staticSprite(700, 468, "lever")
			.setDisplaySize(42, 50);

		const staticBody = this.lever.body as Phaser.Physics.Arcade.StaticBody;
		staticBody.setCircle(12, 9, 26);
		this.solids?.add(this.lever);

		this.tweens.add({
			targets: this.lever,
			angle: 5,
			duration: 1200,
			yoyo: true,
			repeat: -1,
			ease: "Sine.easeInOut",
		});

		this.add
			.text(700, 518, "Рычаг", {
				fontFamily: "Arial",
				fontSize: "14px",
				color: "#f8fafc",
			})
			.setOrigin(0.5);
		this.interactables.push({
			name: "Рычаг",
			object: this.lever,
			action: () => this.pullLever(),
		});
	}

	private createPuzzle(): void {
		switch (this.getPuzzleType()) {
			case "maze":
				this.createMazePuzzle();
				break;
			case "word_search":
				this.createWordSearchPuzzle();
				break;
			case "rhythm":
				this.createRhythmPuzzle();
				break;
			case "pairs":
				this.createMemoryMatchPuzzle();
				break;
			case "platformer":
				this.createPlatformerPuzzle();
				break;
			case "final":
				this.createFinalChallengePuzzle();
				break;
			case "riddle":
				this.createRiddlePuzzle();
				break;
			case "sound_trap":
				this.createSoundTrapPuzzle();
				break;
			case "jumping_path":
				this.createJumpingPathPuzzle();
				break;
			case "memory_advanced":
				this.createAdvancedMemoryPuzzle();
				break;
			case "cave_song":
				this.createCaveSongPuzzle();
				break;
			case "epic_finale":
				this.createEpicFinalePuzzle();
				break;
			case "math_puzzle":
				this.createMathPuzzle();
				break;
			case "simon_says":
				this.createSimonSaysPuzzle();
				break;
			case "tic_tac_toe":
				this.createTicTacToePuzzle();
				break;
		}
	}

	private createPlatformerPuzzle(): void {
		const platforms = [
			{ x: 160, y: 500, w: 100, h: 20 },
			{ x: 330, y: 450, w: 100, h: 20 },
			{ x: 520, y: 400, w: 100, h: 20 },
			{ x: 250, y: 350, w: 100, h: 20 },
			{ x: 430, y: 300, w: 100, h: 20 },
			{ x: 620, y: 250, w: 100, h: 20 },
			{ x: 380, y: 200, w: 100, h: 20 },
		];
		for (const p of platforms) {
			this.createWall(p.x, p.y, p.w, p.h);
		}

		const crystalPositions = [
			{ x: 160, y: 465 },
			{ x: 330, y: 415 },
			{ x: 520, y: 365 },
			{ x: 250, y: 315 },
			{ x: 430, y: 265 },
			{ x: 620, y: 215 },
		];
		this.crystalCount = 0;
		for (const pos of crystalPositions) {
			const crystal = this.add
				.sprite(pos.x, pos.y, "crystal")
				.setDisplaySize(24, 24);

			this.tweens.add({
				targets: crystal,
				scale: 0.9,
				duration: 800,
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});

			this.physics.add.existing(crystal, true);
			const zone = this.add.zone(pos.x, pos.y, 30, 30);
			this.physics.add.existing(zone, true);
			this.autoZones.push({
				zone: zone,
				action: () => {
					if (crystal.active) {
						crystal.destroy();
						this.crystalCount += 1;
						this.refreshStatus(
							`Кристаллов собрано: ${this.crystalCount}/${crystalPositions.length}`,
						);
						if (this.crystalCount >= crystalPositions.length) {
							this.markSolved("Все кристаллы собраны! Теперь опусти рычаг.");
						}
					}
				},
				triggered: false,
			});
		}
	}

	private createMazePuzzle(): void {
		const grid = this.activeMazeGrid;
		const cell = MAZE_CELL_SIZE;
		const startX = MAZE_START_X;
		const startY = MAZE_START_Y;
		this.add
			.rectangle(startX, startY + 13 * cell, 28, 28, 0x38bdf8, 0.35)
			.setStrokeStyle(2, 0x7dd3fc, 0.8);
		this.add
			.text(startX, startY + 13 * cell, "СТ", {
				fontFamily: "Arial",
				fontSize: "10px",
				color: "#e0f2fe",
			})
			.setOrigin(0.5);
		for (const [rowIndex, row] of grid.entries()) {
			for (const [colIndex, value] of [...row].entries()) {
				const x = startX + colIndex * cell;
				const y = startY + rowIndex * cell;
				if (value === "1") {
					this.createWall(x, y, cell, cell);
				} else {
					this.add.rectangle(x, y, cell - 1, cell - 1, 0xf8fafc, 0.1);
				}
			}
		}
		this.add.rectangle(
			startX + MAZE_GOAL_COL * cell,
			startY + MAZE_GOAL_ROW * cell,
			26,
			26,
			0x22c55e,
			0.85,
		);
		this.add
			.sprite(
				startX + MAZE_GOAL_COL * cell,
				startY + MAZE_GOAL_ROW * cell,
				"runeGlow",
			)
			.setTint(0x22c55e)
			.setAlpha(0.55)
			.setScale(0.55)
			.setDepth(7);
		this.add
			.text(startX + MAZE_GOAL_COL * cell, startY + MAZE_GOAL_ROW * cell, "Ф", {
				fontFamily: "Arial",
				fontSize: "16px",
				color: "#052e16",
			})
			.setOrigin(0.5);
		this.add
			.text(
				startX + MAZE_GOAL_COL * cell,
				startY + MAZE_GOAL_ROW * cell + 26,
				"Финиш",
				{
					fontFamily: "Arial",
					fontSize: "11px",
					color: "#bbf7d0",
				},
			)
			.setOrigin(0.5);
		const goal = this.add.zone(
			startX + MAZE_GOAL_COL * cell,
			startY + MAZE_GOAL_ROW * cell,
			28,
			28,
		);
		this.physics.add.existing(goal, true);
		this.autoZones.push({
			zone: goal,
			action: () =>
				this.markSolved(
					"Лабиринт пройден, как в GMS2-версии: доберись до финиша и затем опусти рычаг.",
				),
			triggered: false,
		});
	}

	private createWordSearchPuzzle(): void {
		const wordSearchVariants = [
			{
				rows: [
					"КФЛАБИРИНТ",
					"АЩЦУКЕНГШЗ",
					"ПАЗЗЛОРПАВ",
					"ЫВАПРОЛДЖЭ",
					"ПЕЩЕРАВЫАП",
					"РОЛДЖЭЯЧСМ",
					"ГОРОДКЕНГШ",
					"ЗХЪФЫВАПРО",
					"ЛДЖЭЯЧСМИТ",
					"ЬБЮЙЦУКЕНГ",
				],
			},
			{
				rows: [
					"КРИСТАЛЛГШ",
					"АЩЦУКЕНГШЗ",
					"ЗОЛОТОРАВЗ",
					"ЫВАПРОЛДЖЭ",
					"ПОРТАЛАВЫА",
					"РОЛДЖЭЯЧСМ",
					"ГЕРОЙКЕНГШ",
					"ЗХЪФЫВАПРО",
					"ЛДЖЭЯЧСМИТ",
					"ЬБЮЙЦУКЕНГ",
				],
			},
			{
				rows: [
					"ЗАГАДКАГШЗ",
					"АЩЦУКЕНГШЗ",
					"ПОБЕДАРАВЗ",
					"ЫВАПРОЛДЖЭ",
					"РЫЧАГАВЫАП",
					"РОЛДЖЭЯЧСМ",
					"КАМЕНЬЕНГШ",
					"ЗХЪФЫВАПРО",
					"ЛДЖЭЯЧСМИТ",
					"ЬБЮЙЦУКЕНГ",
				],
			},
		];
		const variant = wordSearchVariants[(this.level - 1) % 3];
		const rows = variant.rows;

		const cell = 30;
		const startX = 190;
		const startY = 190;
		for (const [y, row] of rows.entries()) {
			for (const [x, letter] of [...row].entries()) {
				const rect = this.add
					.rectangle(
						startX + x * cell,
						startY + y * cell,
						cell - 2,
						cell - 2,
						0xf8fafc,
						0.9,
					)
					.setStrokeStyle(1, 0x334155);
				this.add
					.text(rect.x, rect.y, letter, {
						fontFamily: "Arial",
						fontSize: "14px",
						color: "#020617",
					})
					.setOrigin(0.5);
				const wordCell = { x, y, letter, rect };
				this.wordCells.push(wordCell);
				this.interactables.push({
					name: `Буква ${letter}`,
					object: rect,
					action: () => this.selectWordCell(wordCell),
				});
			}
		}
		this.add.text(
			548,
			190,
			`Найди слова:\n${this.wordSearchWords.join("\n")}`,
			{
				fontFamily: "Arial",
				fontSize: "18px",
				color: "#e0f2fe",
				lineSpacing: 8,
			},
		);
	}

	private createRhythmPuzzle(): void {
		this.rhythmRound = 1;
		const colors = [0xff4444, 0x44ff44, 0x4444ff, 0xffff44];
		for (let index = 0; index < 4; index += 1) {
			const x = 235 + index * 110;
			const button = this.add
				.sprite(x, 305, "button")
				.setDisplaySize(80, 80)
				.setTint(colors[index])
				.setAlpha(0.6);

			this.rhythmButtons.push(button as any);
			this.add
				.text(x, 305, `${index + 1}`, {
					fontFamily: "Arial Black",
					fontSize: "32px",
					color: "#ffffff",
					stroke: "#000000",
					strokeThickness: 4,
				})
				.setOrigin(0.5);
			this.interactables.push({
				name: `Кнопка ${index + 1}`,
				object: button,
				action: () => this.pressRhythmButton(index),
			});
		}
		this.startRhythmRound();
		this.showRhythmPattern();
	}

	private createMemoryMatchPuzzle(): void {
		const symbols = ["💎", "🏆", "🌟", "🔥", "💎", "🏆", "🌟", "🔥"];
		const shuffled = this.shuffle(symbols);
		for (const [index, symbol] of shuffled.entries()) {
			const col = index % 4;
			const row = Math.floor(index / 4);
			const x = 250 + col * 100;
			const y = 275 + row * 86;

			const rect = this.add
				.sprite(x, y, "uiPanel")
				.setDisplaySize(80, 70)
				.setTint(0x4a5568);

			const label = this.add
				.text(x, y, "?", {
					fontFamily: "Arial",
					fontSize: "32px",
					color: "#ffffff",
				})
				.setOrigin(0.5);
			const card = {
				index,
				symbol,
				rect: rect as any,
				label,
				revealed: false,
				matched: false,
			};
			this.memoryCards.push(card);
			this.interactables.push({
				name: `Карта ${index + 1}`,
				object: rect,
				action: () => this.flipMemoryCard(card),
			});
		}
	}

	private createFinalChallengePuzzle(): void {
		this.add.text(
			210,
			230,
			"Финальное испытание арки: активируй 3 руны в порядке 1 → 2 → 3. Можно нажимать цифры 1–3.",
			{
				fontFamily: "Arial",
				fontSize: "18px",
				color: "#f8fafc",
				wordWrap: { width: 430 },
			},
		);
		this.finalNextRune = 1;
		for (const rune of [
			{ x: 270, y: 350, id: 1 },
			{ x: 400, y: 292, id: 2 },
			{ x: 530, y: 350, id: 3 },
		]) {
			const sprite = this.add
				.sprite(rune.x, rune.y, "magicCircle")
				.setTint(this.theme.accent)
				.setScale(0.8)
				.setAlpha(0.75);
			this.add
				.text(rune.x, rune.y, String(rune.id), {
					fontFamily: "Arial Black",
					fontSize: "24px",
					color: "#ffffff",
				})
				.setOrigin(0.5);
			this.interactables.push({
				name: `Руна ${rune.id}`,
				object: sprite,
				action: () => this.pressFinalRune(rune.id, sprite),
			});
		}
	}

	private pressFinalRune(id: number, sprite?: Phaser.GameObjects.Sprite): void {
		if (id !== this.finalNextRune) {
			this.finalNextRune = 1;
			this.refreshStatus("Порядок сбился. Начни с первой руны.");
			return;
		}
		sprite?.setAlpha(1).setTint(0x86efac);
		this.finalNextRune += 1;
		if (this.finalNextRune > 3) {
			this.markSolved("Руны активированы. Финальное испытание пройдено.");
		} else {
			this.refreshStatus(`Верно. Теперь руна ${this.finalNextRune}.`);
		}
	}

	private createRiddlePuzzle(): void {
		const riddles = this.riddlesList;
		const correctAnswers = riddles.map((r) => r.answer);
		const ALL_ANSWERS = [
			"ДЫМ",
			"ВРЕМЯ",
			"МОНЕТА",
			"МОРОЗ",
			"СНЕГ",
			"ОБЕЩАНИЕ",
			"ЗАМОК",
			"ЛУК",
		];
		const otherAnswers = ALL_ANSWERS.filter(
			(ans) => !correctAnswers.includes(ans),
		);
		const randomWrong =
			otherAnswers[Phaser.Math.Between(0, otherAnswers.length - 1)];
		const options = this.shuffle([...correctAnswers, randomWrong]);

		const questionText = this.add.text(180, 215, "", {
			fontFamily: "Arial",
			fontSize: "20px",
			color: "#f8fafc",
			wordWrap: { width: 470 },
		});
		const refreshQuestion = () => {
			const riddle = riddles[this.riddleIndex];
			questionText.setText(
				`Загадка ${this.riddleIndex + 1}/${riddles.length}: ${riddle.question}`,
			);
		};
		refreshQuestion();
		for (const [index, option] of options.entries()) {
			const x = 210 + (index % 2) * 240;
			const y = 315 + Math.floor(index / 2) * 70;
			const button = this.add
				.sprite(x, y, "button")
				.setDisplaySize(180, 48)
				.setTint(this.theme.accent)
				.setAlpha(0.65);
			this.add
				.text(x, y, `${index + 1}. ${option}`, {
					fontFamily: "Arial",
					fontSize: "18px",
					color: "#ffffff",
				})
				.setOrigin(0.5);
			this.interactables.push({
				name: `Ответ ${option}`,
				object: button,
				action: () => this.pressRiddleAnswer(option, refreshQuestion),
			});
		}
	}

	private pressRiddleAnswer(
		answer: string,
		refreshQuestion?: () => void,
	): void {
		if (answer !== this.riddleAnswers[this.riddleIndex]) {
			this.refreshStatus("Ответ не подходит. Сфинкс ждёт другой вариант.");
			return;
		}
		this.riddleIndex += 1;
		if (this.riddleIndex >= this.riddleAnswers.length) {
			this.markSolved("Все загадки Сфинкса решены.");
		} else {
			refreshQuestion?.();
			this.refreshStatus("Верно. Следующая загадка.");
		}
	}

	private createSoundTrapPuzzle(): void {
		const notes = ["до", "ре", "ми", "фа", "соль", "ля", "си"];
		this.soundTrapInputIndex = 0;
		this.add.text(
			160,
			210,
			"Звуковые ловушки: нажми E у кнопок или цифры 1–7, чтобы прослушать ноты.",
			{
				fontFamily: "Arial",
				fontSize: "18px",
				color: "#f8fafc",
				wordWrap: { width: 520 },
			},
		);
		this.add.text(
			160,
			252,
			"Задача: активируй 5 рунных кнопок в порядке ВОЗРАСТАНИЯ высоты их звука.",
			{
				fontFamily: "Arial",
				fontSize: "16px",
				color: this.theme.labelColor,
				wordWrap: { width: 520 },
			},
		);
		// Выводим только те 5 кнопок нот, которые сгенерированы в soundTrapSequence!
		for (const [index, noteIndex] of this.soundTrapSequence.entries()) {
			const x = 200 + index * 105;
			const note = notes[noteIndex];
			const button = this.add
				.sprite(x, 365, "button")
				.setDisplaySize(80, 52)
				.setTint(this.theme.accent)
				.setAlpha(0.62);
			this.add
				.text(x, 365, `Рум ${index + 1}`, {
					fontFamily: "Arial",
					fontSize: "15px",
					color: "#fff",
					align: "center",
				})
				.setOrigin(0.5);
			this.interactables.push({
				name: `Кнопка ${index + 1}`,
				object: button,
				action: () => {
					this.refreshStatus(`Звучит нота: ${note}`);
					this.pressSequenceButton(
						noteIndex,
						this.soundTrapCorrectSequence,
						"sound",
					);
				},
			});
		}
	}

	private createJumpingPathPuzzle(): void {
		const path = this.jumpingPath;
		this.jumpingSafeIndex = 0;
		this.add.text(
			178,
			212,
			"Прыгающий путь: сопоставь чертеж на стене и наступай на плиты строго по схеме.",
			{
				fontFamily: "Arial",
				fontSize: "18px",
				color: "#f8fafc",
			},
		);

		// Создаем красивый пиксельный чертеж-карту на стене
		const schemaRows = ["", "", ""];
		for (let lane = 0; lane < 3; lane++) {
			let rowText = `Дорожка ${lane + 1}: `;
			for (let step = 0; step < path.length; step++) {
				rowText += path[step] === lane ? " [X] " : " [ ] ";
			}
			schemaRows[lane] = rowText;
		}

		this.add.text(
			178,
			242,
			`Схема прохода на стене:\n${schemaRows.join("\n")}`,
			{
				fontFamily: "Courier New",
				fontSize: "15px",
				color: this.theme.labelColor,
				lineSpacing: 4,
			},
		);
		this.add.text(
			178,
			246,
			`Порядок дорожек: ${path.map((i) => i + 1).join(" → ")}`,
			{
				fontFamily: "Arial",
				fontSize: "18px",
				color: this.theme.labelColor,
			},
		);
		for (let step = 0; step < path.length; step += 1) {
			for (let lane = 0; lane < 3; lane += 1) {
				const x = 230 + step * 82;
				const y = 320 + lane * 46;
				const tile = this.add
					.rectangle(
						x,
						y,
						62,
						34,
						lane === path[step] ? 0x14532d : 0x450a0a,
						0.8,
					)
					.setStrokeStyle(2, this.theme.accent);
				this.interactables.push({
					name: `Плита ${step + 1}-${lane + 1}`,
					object: tile,
					action: () => this.pressJumpingPathTile(step, lane, tile),
				});
			}
		}
	}

	private pressJumpingPathTile(
		step: number,
		lane: number,
		tile?: Phaser.GameObjects.Rectangle,
	): void {
		if (step !== this.jumpingSafeIndex || lane !== this.jumpingPath[step]) {
			this.jumpingSafeIndex = 0;
			this.refreshStatus("Плита провалилась. Начни путь заново.");
			return;
		}
		tile?.setFillStyle(0x22c55e, 1);
		this.jumpingSafeIndex += 1;
		if (this.jumpingSafeIndex >= this.jumpingPath.length) {
			this.markSolved("Прыгающий путь пройден.");
		}
	}

	private createAdvancedMemoryPuzzle(): void {
		this.createMemoryMatchPuzzle();
		this.add.text(
			164,
			205,
			"Advanced Memory: пары нужно запоминать быстрее — как расширенный GMS2-тип.",
			{
				fontFamily: "Arial",
				fontSize: "16px",
				color: this.theme.labelColor,
			},
		);
	}

	private generateSongClues(seq: number[]): string[] {
		const labels = ["I", "II", "III", "IV", "V"];
		const clues: string[] = [];
		clues.push(`1. Руна ${labels[seq[0]]} пробуждается самой первой.`);
		clues.push(`2. Руна ${labels[seq[4]]} замыкает круг и звучит последней.`);
		clues.push(`3. Руна ${labels[seq[2]]} находится ровно посередине песни.`);
		clues.push(
			`4. Руна ${labels[seq[1]]} поётся раньше, чем руна ${labels[seq[3]]}.`,
		);
		return clues;
	}

	private createCaveSongPuzzle(): void {
		this.songInputIndex = 0;
		const labels = ["I", "II", "III", "IV", "V"];
		this.add.text(
			174,
			218,
			"Песнь пещер: разгадай логический шифр рун на стене.",
			{
				fontFamily: "Arial",
				fontSize: "19px",
				color: "#f8fafc",
			},
		);

		const clues = this.generateSongClues(this.songSequence);
		this.add.text(
			174,
			246,
			`Древние рунические манускрипты гласят:\n${clues.join("\n")}`,
			{
				fontFamily: "Arial",
				fontSize: "15px",
				color: this.theme.labelColor,
				lineSpacing: 4,
			},
		);
		for (const [index, label] of labels.entries()) {
			const x = 215 + index * 92;
			const rune = this.add
				.sprite(x, 365, "runeGlow")
				.setTint(this.theme.accent)
				.setScale(0.82);
			this.add
				.text(x, 365, label, {
					fontFamily: "Arial Black",
					fontSize: "18px",
					color: "#fff",
				})
				.setOrigin(0.5);
			this.interactables.push({
				name: `Руна песни ${label}`,
				object: rune,
				action: () =>
					this.pressSequenceButton(index, this.songSequence, "song"),
			});
		}
	}

	private createEpicFinalePuzzle(): void {
		this.createFinalChallengePuzzle();
		this.add.text(
			170,
			180,
			"Эпический финал: объединённая проверка порядка, памяти и рун.",
			{
				fontFamily: "Arial",
				fontSize: "18px",
				color: this.theme.labelColor,
			},
		);
	}

	private pressSequenceButton(
		index: number,
		sequence: number[],
		mode: "sound" | "song",
	): void {
		const currentIndex =
			mode === "sound" ? this.soundTrapInputIndex : this.songInputIndex;
		if (index !== sequence[currentIndex]) {
			if (mode === "sound") this.soundTrapInputIndex = 0;
			else this.songInputIndex = 0;
			this.refreshStatus("Последовательность сбилась. Повтори сначала.");
			return;
		}
		const nextIndex = currentIndex + 1;
		if (mode === "sound") this.soundTrapInputIndex = nextIndex;
		else this.songInputIndex = nextIndex;
		if (nextIndex >= sequence.length) {
			this.markSolved(
				mode === "sound"
					? "Звуковые ловушки обезврежены."
					: "Песнь пещер прозвучала верно.",
			);
		} else {
			this.refreshStatus(`Верно. Шаг ${nextIndex + 1}/${sequence.length}.`);
		}
	}

	private handleNumberInput(): void {
		if (this.solved) return;

		const pressedIndex = this.numberKeys.findIndex((key) =>
			Phaser.Input.Keyboard.JustDown(key),
		);
		if (pressedIndex < 0) return;

		const type = this.getPuzzleType();
		if (type === "rhythm" && pressedIndex < 4) {
			this.pressRhythmButton(pressedIndex);
			return;
		}

		if (type === "final" || type === "epic_finale") {
			if (pressedIndex < 3) this.pressFinalRune(pressedIndex + 1);
			return;
		}

		if (type === "riddle") {
			const options = ["ДЫМ", "КАМЕНЬ", "ВРЕМЯ", "МОНЕТА"];
			const answer = options[pressedIndex];
			if (answer) this.pressRiddleAnswer(answer);
			return;
		}

		if (type === "sound_trap" && pressedIndex < 7) {
			this.pressSequenceButton(pressedIndex, this.soundTrapSequence, "sound");
			return;
		}

		if (type === "cave_song" && pressedIndex < 5) {
			this.pressSequenceButton(pressedIndex, this.songSequence, "song");
			return;
		}

		if (type === "jumping_path" && pressedIndex < 3) {
			this.pressJumpingPathTile(this.jumpingSafeIndex, pressedIndex);
			return;
		}

		if (type === "tic_tac_toe" && pressedIndex < 9) {
			this.pressTicTacToeCell(pressedIndex);
		}
	}

	private selectWordCell(cell: WordCell): void {
		if (!this.wordStart) {
			this.wordStart = cell;
			const rect = cell.rect as unknown as Phaser.GameObjects.GameObject;
			if ("setTint" in rect) {
				(rect as unknown as Phaser.GameObjects.Components.Tint).setTint(
					0x93c5fd,
				);
			} else if ("setFillStyle" in rect) {
				(rect as unknown as Phaser.GameObjects.Rectangle).setFillStyle(
					0x93c5fd,
					1,
				);
			}
			this.refreshStatus(`Начало: ${cell.letter}. Выбери конец слова.`);
			return;
		}

		const selected = this.getWordBetween(this.wordStart, cell);
		if (!selected) {
			const startRect = this.wordStart
				.rect as unknown as Phaser.GameObjects.GameObject;
			if ("setTint" in startRect) {
				(startRect as unknown as Phaser.GameObjects.Components.Tint).setTint(
					0xffffff,
				);
			} else if ("setFillStyle" in startRect) {
				(startRect as unknown as Phaser.GameObjects.Rectangle).setFillStyle(
					0xf8fafc,
					1,
				);
			}
			this.wordStart = undefined;
			this.refreshStatus("Выбирай по прямой!");
			return;
		}

		const reversed = [...selected.word].reverse().join("");
		const target = this.wordSearchWords.find(
			(word) => word === selected.word || word === reversed,
		);

		if (target && !this.foundWords.has(target)) {
			this.foundWords.add(target);
			for (const foundCell of selected.cells) {
				const foundRect =
					foundCell.rect as unknown as Phaser.GameObjects.GameObject;
				if ("setTint" in foundRect) {
					(foundRect as unknown as Phaser.GameObjects.Components.Tint).setTint(
						0x86efac,
					);
				} else if ("setFillStyle" in foundRect) {
					(foundRect as unknown as Phaser.GameObjects.Rectangle).setFillStyle(
						0x86efac,
						1,
					);
				}
			}
			if (this.foundWords.size >= 4) {
				this.markSolved("Слова найдены! Опусти рычаг.");
			} else {
				this.refreshStatus(
					`Найдено: ${target}. Ещё ${4 - this.foundWords.size}.`,
				);
			}
		} else {
			const startRect = this.wordStart
				.rect as unknown as Phaser.GameObjects.GameObject;
			if ("setTint" in startRect) {
				(startRect as unknown as Phaser.GameObjects.Components.Tint).setTint(
					0xffffff,
				);
			} else if ("setFillStyle" in startRect) {
				(startRect as unknown as Phaser.GameObjects.Rectangle).setFillStyle(
					0xf8fafc,
					1,
				);
			}
			this.refreshStatus("Не то слово...");
		}
		this.wordStart = undefined;
	}

	private getWordBetween(
		start: WordCell,
		end: WordCell,
	): { word: string; cells: WordCell[] } | undefined {
		const dx = Math.sign(end.x - start.x);
		const dy = Math.sign(end.y - start.y);
		if (
			start.x !== end.x &&
			start.y !== end.y &&
			Math.abs(end.x - start.x) !== Math.abs(end.y - start.y)
		) {
			return undefined;
		}
		let x = start.x;
		let y = start.y;
		let word = "";
		const cells: WordCell[] = [];
		while (true) {
			const cell = this.wordCells.find(
				(candidate) => candidate.x === x && candidate.y === y,
			);
			if (!cell) {
				return undefined;
			}
			word += cell.letter;
			cells.push(cell);
			if (x === end.x && y === end.y) {
				break;
			}
			x += dx;
			y += dy;
		}
		return { word, cells };
	}

	private startRhythmRound(): void {
		this.rhythmSequence = Array.from({ length: this.rhythmRound }, () =>
			Phaser.Math.Between(0, 3),
		);
		this.rhythmInputIndex = 0;
	}

	private showRhythmPattern(): void {
		this.rhythmShowing = true;
		this.refreshStatus(
			`Раунд ${this.rhythmRound}/4: запомни подсветку кнопок, потом подойди к ним героем.`,
		);
		const colors = [0xef4444, 0x3b82f6, 0x10b981, 0xf59e0b];
		for (const [index, buttonIndex] of this.rhythmSequence.entries()) {
			this.time.delayedCall(450 + index * 520, () => {
				const button = this.rhythmButtons[buttonIndex];
				if (button) {
					button.setAlpha(1);
					if ("texture" in button && button.texture.key === "crystal") {
						(button as Phaser.GameObjects.Sprite).setTint(colors[buttonIndex]);
						this.time.delayedCall(260, () => {
							button.setAlpha(0.7);
							(button as Phaser.GameObjects.Sprite).setTint(0x475569);
						});
					} else {
						this.time.delayedCall(260, () => button.setAlpha(0.45));
					}
				}
			});
		}
		this.time.delayedCall(700 + this.rhythmSequence.length * 520, () => {
			this.rhythmShowing = false;
			this.refreshStatus(
				"Теперь повтори последовательность: подходи к цветным кнопкам и нажимай E/Space.",
			);
		});
	}

	private pressRhythmButton(index: number): void {
		if (this.rhythmShowing) {
			this.refreshStatus("Подожди, пока паттерн закончится.");
			return;
		}

		// Подсвечиваем нажатый кристалл/кнопку
		const colors = [0xef4444, 0x3b82f6, 0x10b981, 0xf59e0b];
		const button = this.rhythmButtons[index];
		if (button) {
			button.setAlpha(1);
			if ("texture" in button && button.texture.key === "crystal") {
				(button as Phaser.GameObjects.Sprite).setTint(colors[index]);
				this.time.delayedCall(200, () => {
					button.setAlpha(0.7);
					(button as Phaser.GameObjects.Sprite).setTint(0x475569);
				});
			} else {
				this.time.delayedCall(200, () => button.setAlpha(0.45));
			}
		}

		if (index !== this.rhythmSequence[this.rhythmInputIndex]) {
			this.refreshStatus("Ошибка ритма. Раунд начался заново.");
			this.startRhythmRound();
			this.showRhythmPattern();
			return;
		}
		this.rhythmInputIndex += 1;
		if (this.rhythmInputIndex < this.rhythmSequence.length) {
			this.refreshStatus(
				`Верно. Осталось нажать ${this.rhythmSequence.length - this.rhythmInputIndex}.`,
			);
			return;
		}
		if (this.rhythmRound >= 4) {
			this.markSolved(
				"Ритм пройден. В GMS2 максимум 8 раундов, в web-port пока 4 для быстрого прохождения.",
			);
			return;
		}
		this.rhythmRound += 1;
		this.startRhythmRound();
		this.showRhythmPattern();
	}

	private flipMemoryCard(card: MemoryCard): void {
		if (this.memoryLocked || card.matched || card.revealed) {
			return;
		}
		card.revealed = true;

		const rect = card.rect as unknown as Phaser.GameObjects.GameObject;
		if ("setTint" in rect) {
			(rect as unknown as Phaser.GameObjects.Components.Tint).setTint(0xffffff);
		}

		card.label.setText(card.symbol).setColor("#000000");
		if (!this.firstMemoryCard) {
			this.firstMemoryCard = card;
			this.refreshStatus("Первая карта открыта. Найди пару!");
			return;
		}
		if (this.firstMemoryCard.symbol === card.symbol) {
			card.matched = true;
			this.firstMemoryCard.matched = true;

			const firstRect = this.firstMemoryCard
				.rect as unknown as Phaser.GameObjects.GameObject;
			if ("setTint" in rect) {
				(rect as unknown as Phaser.GameObjects.Components.Tint).setTint(
					0x86efac,
				);
			}
			if ("setTint" in firstRect) {
				(firstRect as unknown as Phaser.GameObjects.Components.Tint).setTint(
					0x86efac,
				);
			}

			this.firstMemoryCard = undefined;
			if (this.memoryCards.every((item) => item.matched)) {
				this.markSolved("Все пары найдены! Опусти рычаг.");
				return;
			}
			this.refreshStatus("Пара найдена!");
			return;
		}
		const previous = this.firstMemoryCard;
		this.firstMemoryCard = undefined;
		this.memoryLocked = true;
		this.refreshStatus("Не совпало...");
		this.time.delayedCall(800, () => {
			for (const item of [previous, card]) {
				item.revealed = false;
				const itemRect = item.rect as unknown as Phaser.GameObjects.GameObject;
				if ("setTint" in itemRect) {
					(itemRect as unknown as Phaser.GameObjects.Components.Tint).setTint(
						0x4a5568,
					);
				}
				item.label.setText("?").setColor("#ffffff");
			}
			this.memoryLocked = false;
		});
	}

	private interact(): void {
		if (!this.player) {
			return;
		}
		const nearest = this.getNearestInteractable(40);
		if (!nearest) {
			this.refreshStatus("Подойди вплотную к объекту пазла или рычагу.");
			return;
		}
		nearest.action();
	}

	private getNearestInteractable(
		maxDistance: number,
	): Interactable | undefined {
		if (!this.player) return undefined;
		let nearest: Interactable | undefined;
		let nearestDistance = maxDistance;

		for (const item of this.interactables) {
			const position = this.getObjectPosition(item.object);
			const distance = Phaser.Math.Distance.Between(
				this.player.x,
				this.player.y,
				position.x,
				position.y,
			);
			if (distance < nearestDistance) {
				nearest = item;
				nearestDistance = distance;
			}
		}

		return nearest;
	}

	private updateInteractableFocus(): void {
		const nearest = this.getNearestInteractable(62);
		if (!nearest || !this.focusRing) {
			this.focusRing?.setVisible(false);
			return;
		}
		const position = this.getObjectPosition(nearest.object);
		this.focusRing
			.setPosition(position.x, position.y)
			.setVisible(true)
			.setAlpha(0.62 + Math.sin(this.time.now / 130) * 0.28);
	}

	private triggerAutoZone(autoZone: AutoZone): void {
		if (autoZone.triggered) {
			return;
		}
		autoZone.triggered = true;
		autoZone.action();
	}

	private getObjectPosition(object: Phaser.GameObjects.GameObject): {
		x: number;
		y: number;
	} {
		const positioned =
			object as unknown as Phaser.GameObjects.Components.Transform;
		return { x: positioned.x, y: positioned.y };
	}

	private refreshStatus(text: string): void {
		this.statusText?.setText(text);
	}

	private markSolved(text: string): void {
		if (this.solved) {
			return;
		}
		this.solved = true;
		this.refreshStatus(text);

		const solvedMsg = this.add
			.text(480, 282, "РЕШЕНО!", {
				fontFamily: "Arial Black",
				fontSize: "64px",
				color: "#22c55e",
				stroke: "#064e3b",
				strokeThickness: 8,
			})
			.setOrigin(0.5)
			.setDepth(100)
			.setAlpha(0);

		this.tweens.add({
			targets: solvedMsg,
			alpha: 1,
			scale: { from: 0.5, to: 1.2 },
			duration: 600,
			ease: "Back.easeOut",
			yoyo: true,
			hold: 1000,
			onComplete: () => solvedMsg.destroy(),
		});
	}

	private pullLever(): void {
		if (!this.solved) {
			this.refreshStatus(
				"Рычаг пока не поддаётся. Сначала реши задачу героем.",
			);
			return;
		}
		const progress = completeLevel(loadProgress(), this.level);
		saveProgress(progress);
		if (this.level >= LEVEL_COUNT) {
			this.scene.start("VictoryScene");
			return;
		}
		// Переход через паркур-сцену вместо прямого возврата в город
		this.scene.start("TransitionScene", {
			fromLevel: this.level,
			toLevel: this.level + 1,
		});
	}

	private getPuzzleName(): string {
		const names: Record<PuzzleType, string> = {
			maze: "Лабиринт",
			word_search: "Поиск слов",
			rhythm: "Ритм/Паттерн",
			pairs: "Memory Match",
			platformer: "Платформер",
			final: "Финальное испытание",
			riddle: "Загадки Сфинкса",
			sound_trap: "Звуковые ловушки",
			jumping_path: "Прыгающий путь",
			memory_advanced: "Advanced Memory",
			cave_song: "Песнь пещер",
			epic_finale: "Эпический финал",
			math_puzzle: "Магическая арифметика",
			simon_says: "Световые кристаллы",
			tic_tac_toe: "Крестики-Нолики",
		};
		return names[this.getPuzzleType()];
	}

	private getPuzzlePrompt(): string {
		switch (this.getPuzzleType()) {
			case "maze":
				return "Лабиринт: стрелками двигай героя точно, WASD запускает скольжение до стены. Доберись до зелёного финиша; он не двигается.";
			case "word_search":
				return "Поиск слов: выбери первую и последнюю букву слова прямой линией через E/Space. Синяя линия подскажет выбор.";
			case "rhythm":
				return "Ритм: запоминай последовательность цветных кнопок и повторяй её героем.";
			case "pairs":
				return "Memory Match: открывай карты героем, ищи пары и жди, если карты не совпали.";
			case "platformer":
				return "Платформер: прыгай по парящим островам и собери все кристаллы.";
			case "final":
				return "Финальное испытание: активируй руны в правильном порядке, затем опусти рычаг.";
			case "riddle":
				return "Загадки: подходи к варианту ответа и нажимай E/Space.";
			case "sound_trap":
				return "Звуковые ловушки: повторяй последовательность нот, как в GMS2-версии.";
			case "jumping_path":
				return "Прыгающий путь: выбирай безопасные плиты в указанном порядке.";
			case "memory_advanced":
				return "Advanced Memory: усложнённая версия поиска пар.";
			case "cave_song":
				return "Песнь пещер: нажимай руны в порядке мелодии.";
			case "epic_finale":
				return "Эпический финал: заверши комбинированное испытание рун.";
			case "math_puzzle":
				return "Арифметика: реши уравнение на стене и встань на соответствующую плиту.";
			case "simon_says":
				return "Кристаллы: повтори последовательность вспышек кристаллов.";
			case "tic_tac_toe":
				return "Крестики-Нолики: подходи к клетке и жми E/Space, или клавишами 1-9. Поставь три X в ряд и победи компьютер!";
		}
	}

	private getPuzzleType(): PuzzleType {
		if (this.level <= 15) {
			return PUZZLE_TYPES[this.level - 1];
		}
		// Перетасованная нелинейная последовательность для уровней 16-36 (включает tic_tac_toe)
		const SHUFFLED_ORDER: number[] = [
			4, 0, 7, 1, 14, 10, 2, 8, 3, 11, 5, 9, 6, 12, 13, 5, 8, 2, 14, 11, 0, 13,
		];
		const index = SHUFFLED_ORDER[(this.level - 16) % SHUFFLED_ORDER.length];
		return PUZZLE_TYPES[index];
	}

	private approach(current: number, target: number, amount: number): number {
		if (current < target) return Math.min(current + amount, target);
		if (current > target) return Math.max(current - amount, target);
		return target;
	}

	private shuffle<T>(items: T[]): T[] {
		const result = [...items];
		for (let index = result.length - 1; index > 0; index -= 1) {
			const swapIndex = Phaser.Math.Between(0, index);
			[result[index], result[swapIndex]] = [result[swapIndex], result[index]];
		}
		return result;
	}

	private createMathPuzzle(): void {
		this.add.text(174, 212, "Магическая арифметика: найди число на плите.", {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#f8fafc",
		});
		this.add.text(174, 246, `Реши уравнение: ${this.mathQuestion}`, {
			fontFamily: "Arial",
			fontSize: "24px",
			color: this.theme.labelColor,
		});
		for (const [index, option] of this.mathOptions.entries()) {
			const x = 240 + index * 160;
			const y = 370;
			const tile = this.add
				.rectangle(x, y, 92, 64, 0x1e293b, 0.95)
				.setStrokeStyle(2, this.theme.accent);
			this.add
				.text(x, y, String(option), {
					fontFamily: "Arial Black",
					fontSize: "22px",
					color: "#ffffff",
				})
				.setOrigin(0.5);
			this.interactables.push({
				name: `Число ${option}`,
				object: tile,
				action: () => this.pressMathTile(option, tile),
			});
		}
	}

	private pressMathTile(val: number, tile: Phaser.GameObjects.Rectangle): void {
		if (this.solved) return;
		if (val === this.mathAnswer) {
			tile.setFillStyle(0x22c55e, 1);
			this.cameras.main.shake(100, 0.003);
			this.markSolved("Уравнение решено! Опусти рычаг.");
		} else {
			tile.setFillStyle(0xef4444, 1);
			this.cameras.main.shake(150, 0.005);
			this.refreshStatus("Неверно! Попробуй другую плиту.");
			this.time.delayedCall(800, () => {
				tile.setFillStyle(0x1e293b, 0.95);
			});
		}
	}

	private createSimonSaysPuzzle(): void {
		this.rhythmRound = 1;
		this.rhythmButtons.length = 0;
		this.startRhythmRound();

		this.add.text(174, 212, "Световые кристаллы: повтори вспышки кристаллов.", {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#f8fafc",
		});

		const names = ["Красный", "Синий", "Зеленый", "Желтый"];
		for (let i = 0; i < 4; i++) {
			const x = 200 + i * 130;
			const y = 350;

			const crystal = this.add
				.sprite(x, y, "crystal")
				.setDisplaySize(64, 64)
				.setTint(0x475569) // Потухший
				.setAlpha(0.7);

			this.rhythmButtons.push(crystal);
			this.add
				.text(x, y + 42, names[i], {
					fontFamily: "Arial",
					fontSize: "14px",
					color: "#ffffff",
				})
				.setOrigin(0.5);

			this.interactables.push({
				name: `${names[i]} кристалл`,
				object: crystal,
				action: () => this.pressRhythmButton(i),
			});
		}

		this.time.delayedCall(1000, () => this.showRhythmPattern());
	}

	// ===== КРЕСТИКИ-НОЛИКИ =====

	private createTicTacToePuzzle(): void {
		this.ticTacToeLocked = false;

		this.add.text(174, 200, "Крестики-Нолики: победи компьютер!", {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#f8fafc",
		});
		this.add.text(
			174,
			228,
			"Подходи к клетке и жми E/Space, или клавиши 1-9.",
			{
				fontFamily: "Arial",
				fontSize: "14px",
				color: "#94a3b8",
			},
		);

		const STEP = 88;
		const CX = 420;
		const CY = 330;

		for (let i = 0; i < 9; i++) {
			const col = i % 3;
			const row = Math.floor(i / 3);
			const x = CX + (col - 1) * STEP;
			const y = CY + (row - 1) * STEP;

			const rect = this.add
				.rectangle(x, y, 78, 78, 0x1e293b, 0.95)
				.setStrokeStyle(2, this.theme.accent);
			this.ticTacToeRects.push(rect);

			const label = this.add
				.text(x, y, String(i + 1), {
					fontFamily: "Arial Black",
					fontSize: "18px",
					color: "#475569",
				})
				.setOrigin(0.5);
			this.ticTacToeLabels.push(label);

			const cellIndex = i;
			this.interactables.push({
				name: `Клетка ${i + 1}`,
				object: rect,
				action: () => this.pressTicTacToeCell(cellIndex),
			});
		}
	}

	private pressTicTacToeCell(index: number): void {
		if (this.solved || this.ticTacToeLocked) return;
		if (this.ticTacToeBoard[index] !== "") return;

		// Ход игрока
		this.ticTacToeBoard[index] = "X";
		this.ticTacToeRects[index]?.setFillStyle(0x1d4ed8, 0.95);
		this.ticTacToeLabels[index]?.setText("X").setStyle({
			color: "#60a5fa",
			fontSize: "32px",
			fontFamily: "Arial Black",
		});
		this.cameras.main.shake(60, 0.002);

		const result = this.checkTicTacToeWinner();
		if (result === "X") {
			this.markSolved("Ты победил в Крестики-Нолики! Опусти рычаг.");
			return;
		}
		if (result === "draw") {
			this.refreshStatus("Ничья! Доска сбрасывается...");
			this.ticTacToeLocked = true;
			this.time.delayedCall(1200, () => this.resetTicTacToeBoard());
			return;
		}

		// Ход ИИ с небольшой задержкой для наглядности
		this.ticTacToeLocked = true;
		this.time.delayedCall(480, () => {
			this.aiTicTacToeMove();
			this.ticTacToeLocked = false;

			const result2 = this.checkTicTacToeWinner();
			if (result2 === "O") {
				this.refreshStatus("Компьютер победил! Доска сбрасывается...");
				this.ticTacToeLocked = true;
				this.time.delayedCall(1200, () => this.resetTicTacToeBoard());
			} else if (result2 === "draw") {
				this.refreshStatus("Ничья! Доска сбрасывается...");
				this.ticTacToeLocked = true;
				this.time.delayedCall(1200, () => this.resetTicTacToeBoard());
			} else {
				this.refreshStatus("Твой ход! Выбери клетку.");
			}
		});
	}

	private aiTicTacToeMove(): void {
		const WIN_LINES = [
			[0, 1, 2],
			[3, 4, 5],
			[6, 7, 8],
			[0, 3, 6],
			[1, 4, 7],
			[2, 5, 8],
			[0, 4, 8],
			[2, 4, 6],
		];
		const b = this.ticTacToeBoard;

		// Попытка выиграть
		for (const [a, m, c] of WIN_LINES) {
			if (b[a] === "O" && b[m] === "O" && b[c] === "") {
				this.placeAiMark(c);
				return;
			}
			if (b[a] === "O" && b[c] === "O" && b[m] === "") {
				this.placeAiMark(m);
				return;
			}
			if (b[m] === "O" && b[c] === "O" && b[a] === "") {
				this.placeAiMark(a);
				return;
			}
		}

		// Блокировка игрока
		for (const [a, m, c] of WIN_LINES) {
			if (b[a] === "X" && b[m] === "X" && b[c] === "") {
				this.placeAiMark(c);
				return;
			}
			if (b[a] === "X" && b[c] === "X" && b[m] === "") {
				this.placeAiMark(m);
				return;
			}
			if (b[m] === "X" && b[c] === "X" && b[a] === "") {
				this.placeAiMark(a);
				return;
			}
		}

		// Центр
		if (b[4] === "") {
			this.placeAiMark(4);
			return;
		}

		// Угол
		for (const i of [0, 2, 6, 8]) {
			if (b[i] === "") {
				this.placeAiMark(i);
				return;
			}
		}

		// Любая свободная клетка
		for (let i = 0; i < 9; i++) {
			if (b[i] === "") {
				this.placeAiMark(i);
				return;
			}
		}
	}

	private placeAiMark(index: number): void {
		this.ticTacToeBoard[index] = "O";
		this.ticTacToeRects[index]?.setFillStyle(0x7c2d12, 0.95);
		this.ticTacToeLabels[index]?.setText("O").setStyle({
			color: "#f87171",
			fontSize: "32px",
			fontFamily: "Arial Black",
		});
	}

	private checkTicTacToeWinner(): "X" | "O" | "draw" | null {
		const WIN_LINES = [
			[0, 1, 2],
			[3, 4, 5],
			[6, 7, 8],
			[0, 3, 6],
			[1, 4, 7],
			[2, 5, 8],
			[0, 4, 8],
			[2, 4, 6],
		];
		const b = this.ticTacToeBoard;
		for (const [a, m, c] of WIN_LINES) {
			if (b[a] && b[a] === b[m] && b[a] === b[c]) {
				return b[a] as "X" | "O";
			}
		}
		if (b.every((cell) => cell !== "")) return "draw";
		return null;
	}

	private resetTicTacToeBoard(): void {
		if (this.solved) return;
		this.ticTacToeBoard = Array(9).fill("") as ("X" | "O" | "")[];
		this.ticTacToeLocked = false;
		for (let i = 0; i < 9; i++) {
			this.ticTacToeRects[i]?.setFillStyle(0x1e293b, 0.95);
			this.ticTacToeLabels[i]?.setText(String(i + 1)).setStyle({
				color: "#475569",
				fontSize: "18px",
				fontFamily: "Arial Black",
			});
		}
		this.refreshStatus("Доска сброшена. Твой ход!");
	}

	private spawnStepParticle(x: number, y: number): void {
		const size = Phaser.Math.Between(2, 4);
		const dust = this.add.rectangle(
			x + Phaser.Math.Between(-8, 8),
			y + 20,
			size,
			size,
			0x475569, // Серая пыль для пещерной земли
			0.7,
		);
		dust.setDepth(19);

		this.tweens.add({
			targets: dust,
			x: dust.x + Phaser.Math.Between(-15, 15),
			y: dust.y - Phaser.Math.Between(5, 15),
			scaleX: 0.1,
			scaleY: 0.1,
			alpha: 0,
			duration: Phaser.Math.Between(300, 600),
			onComplete: () => dust.destroy(),
		});
	}

	private spawnGhostTrail(x: number, y: number): void {
		if (!this.player) return;
		const ghost = this.add
			.sprite(x, y, this.player.texture.key)
			.setScale(this.player.scaleX, this.player.scaleY)
			.setAngle(this.player.angle)
			.setTint(this.theme.accent)
			.setAlpha(0.5)
			.setDepth(18);

		this.tweens.add({
			targets: ghost,
			alpha: 0,
			duration: 250,
			onComplete: () => ghost.destroy(),
		});
	}
}
