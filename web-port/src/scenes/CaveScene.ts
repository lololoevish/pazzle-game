import Phaser from "phaser";
import { LEVEL_COUNT } from "../game/constants";
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
};

const CAVE_THEMES: readonly CaveTheme[] = [
	// 0: Лабиринт — глубокий индиго/фиолетовый
	{
		bgColor: "#1e1b4b",
		panelFill: 0x2e2669,
		wallFill: 0x0f172a,
		wallStroke: 0x475569,
		accent: 0x8b5cf6,
		labelColor: "#c4b5fd",
	},
	// 1: Поиск слов — тёмный океанский синий
	{
		bgColor: "#0c1635",
		panelFill: 0x1e3a5f,
		wallFill: 0x0a1628,
		wallStroke: 0x1e40af,
		accent: 0x3b82f6,
		labelColor: "#93c5fd",
	},
	// 2: Ритм — тёмный багряный
	{
		bgColor: "#1a0505",
		panelFill: 0x450a0a,
		wallFill: 0x180404,
		wallStroke: 0x991b1b,
		accent: 0xef4444,
		labelColor: "#fca5a5",
	},
	// 3: Memory Match — тёмный изумруд
	{
		bgColor: "#041a1a",
		panelFill: 0x064e3b,
		wallFill: 0x022c22,
		wallStroke: 0x065f46,
		accent: 0x10b981,
		labelColor: "#6ee7b7",
	},
	// 4: Платформер — тёмный янтарь
	{
		bgColor: "#1a0c00",
		panelFill: 0x451a03,
		wallFill: 0x1c0a00,
		wallStroke: 0x7c2d12,
		accent: 0xf59e0b,
		labelColor: "#fde68a",
	},
];

const CAVE_BOUNDS = { x: 72, y: 112, width: 816, height: 340 };
const MAZE_CELL_SIZE = 20;
const MAZE_START_X = 270;
const MAZE_START_Y = 128;
const MAZE_START_COL = 0;
const MAZE_START_ROW = 13;
const MAZE_GOAL_COL = 13;
const MAZE_GOAL_ROW = 13;

const MAZE_GRID = [
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
	private solids?: Phaser.Physics.Arcade.StaticGroup;
	private lever?: Phaser.Physics.Arcade.Sprite;
	private readonly interactables: Interactable[] = [];
	private readonly autoZones: AutoZone[] = [];
	private readonly wordCells: WordCell[] = [];
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

	public constructor() {
		super("CaveScene");
	}

	public init(data: CaveData): void {
		this.level = Math.min(
			LEVEL_COUNT,
			Math.max(1, Number(data.level) || loadProgress().currentLevel),
		);
		this.solved = false;
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
		this.theme = CAVE_THEMES[(this.level - 1) % 5];
	}

	public create(): void {
		this.cameras.main.setBackgroundColor(this.theme.bgColor);
		this.add
			.image(480, 270, "caveBackground")
			.setAlpha(0.4)
			.setTint(this.theme.panelFill);
		this.add
			.tileSprite(480, 270, 960, 540, "tileFloor")
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
			.text(480, 68, this.getPuzzleName(), {
				fontFamily: "Arial",
				fontSize: "20px",
				color: this.theme.labelColor,
			})
			.setOrigin(0.5);

		// Основная панель пещеры
		if ("nineslice" in this.add) {
			(this.add as any)
				.nineslice(480, 282, "uiPanel", undefined, 850, 350, 20, 20, 20, 20)
				.setAlpha(0.6);
		} else {
			addPanel(this, 480, 282, 850, 350);
		}

		this.add.text(92, 120, this.getPuzzlePrompt(), {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#f8fafc",
			wordWrap: { width: 760 },
			lineSpacing: 5,
		});
		this.statusText = this.add.text(92, 405, "", {
			fontFamily: "Arial",
			fontSize: "17px",
			color: "#fde68a",
			wordWrap: { width: 760 },
		});

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
		if ((this.level - 1) % 5 === 0) {
			this.player.setDisplaySize(16, 16).setDepth(20);
			this.player.setCircle(7, 1, 1);
		} else {
			this.player.setDisplaySize(36, 44).setDepth(20);
		}
		if (this.solids && (this.level - 1) % 5 !== 0) {
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
			(this.level - 1) % 5 === 0
				? "Лабиринт: стрелки — точное движение, WASD — скольжение до стены, Esc — хаб."
				: "WASD/стрелки — движение, E/Space — действие, Esc — хаб. Проходы работают автоматически.",
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
	}

	public update(): void {
		if (!this.player || !this.cursors || !this.wasd) {
			return;
		}

		const isPlatformer = (this.level - 1) % 5 === 4;
		const speed = 172;

		if (isPlatformer) {
			this.updatePlatformerMovement();
		} else if (!this.solved && (this.level - 1) % 5 === 0) {
			this.updateMazeMovement();
		} else {
			const left = this.cursors.left.isDown || this.wasd.A.isDown;
			const right = this.cursors.right.isDown || this.wasd.D.isDown;
			const up = this.cursors.up.isDown || this.wasd.W.isDown;
			const down = this.cursors.down.isDown || this.wasd.S.isDown;
			this.player.setVelocity(
				(Number(right) - Number(left)) * speed,
				(Number(down) - Number(up)) * speed,
			);
		}

		const pressedInteract = this.interactKey
			? Phaser.Input.Keyboard.JustDown(this.interactKey)
			: false;
		const pressedSpace = this.spaceKey
			? Phaser.Input.Keyboard.JustDown(this.spaceKey)
			: false;
		if (pressedInteract || pressedSpace) {
			this.interact();
		}

		if (this.escKey && Phaser.Input.Keyboard.JustDown(this.escKey)) {
			this.scene.start("TownScene");
		}

		this.updateWordSearchLine();
	}

	private getPlayerStartPosition(): { x: number; y: number } {
		if ((this.level - 1) % 5 === 0) {
			return this.getMazeCellCenter(MAZE_START_COL, MAZE_START_ROW);
		}

		return { x: 128, y: 382 };
	}

	private updatePlatformerMovement(): void {
		if (!this.player || !this.cursors || !this.wasd) return;

		const speed = 200;
		const jumpForce = -450;
		const left = this.cursors.left.isDown || this.wasd.A.isDown;
		const right = this.cursors.right.isDown || this.wasd.D.isDown;
		const jump =
			Phaser.Input.Keyboard.JustDown(this.cursors.up) ||
			Phaser.Input.Keyboard.JustDown(this.wasd.W) ||
			(this.spaceKey && Phaser.Input.Keyboard.JustDown(this.spaceKey));

		this.player.setGravityY(1000);
		this.player.setVelocityX((Number(right) - Number(left)) * speed);

		if (
			jump &&
			(this.player.body?.blocked.down || this.player.body?.touching.down)
		) {
			this.player.setVelocityY(jumpForce);
		}

		// Если упали слишком низко
		if (this.player.y > 450) {
			this.player.setPosition(128, 382);
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
		return MAZE_GRID[row]?.[col] === "0";
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
				480,
				282,
				CAVE_BOUNDS.width,
				CAVE_BOUNDS.height,
				this.theme.panelFill,
				0.45,
			)
			.setStrokeStyle(2, this.theme.accent);
		this.createWall(480, 105, 840, 18);
		this.createWall(480, 460, 840, 18);
		this.createWall(60, 282, 18, 256);
		this.createWall(900, 282, 18, 340);
		this.createWall(190, 208, 150, 20);
		this.createWall(720, 228, 180, 20);
		this.createWall(410, 372, 190, 20);
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
			{ x: 180, y: 416, scale: 0.65, tint: 0xfb7185 },
			{ x: 782, y: 414, scale: 0.55, tint: 0xc084fc },
			{ x: 700, y: 246, scale: 0.44, tint: 0x67e8f9 },
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
			{ x: 636, y: 118, scale: 0.46 },
			{ x: 558, y: 452, scale: 0.5 },
		]) {
			this.add
				.sprite(item.x, item.y, "caveCrystalCluster")
				.setTint(this.theme.accent)
				.setScale(item.scale)
				.setAlpha(0.55)
				.setDepth(4);
		}

		for (const item of [
			{ x: 112, y: 206, scale: 0.68 },
			{ x: 852, y: 212, scale: 0.72 },
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
			{ x: 480, y: 284, scale: 3.8, alpha: 0.06 },
			{ x: 812, y: 382, scale: 1.05, alpha: 0.2 },
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
			{ x: 622, y: 428, scale: 0.65 },
			{ x: 820, y: 254, scale: 0.5 },
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
			{ x: 850, y: 142, scale: 0.9 },
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
			.rectangle(72, 382, 24, 86, 0x14532d, 0.7)
			.setStrokeStyle(2, 0x86efac);
		this.add
			.text(90, 432, "Выход", {
				fontFamily: "Arial",
				fontSize: "14px",
				color: "#dcfce7",
			})
			.setOrigin(0.5);
		const exitZone = this.add.zone(72, 382, 28, 92);
		this.physics.add.existing(exitZone, true);
		this.autoZones.push({
			zone: exitZone,
			action: () => this.scene.start("TownScene"),
			triggered: false,
		});
	}

	private createAtmosphere(): void {
		this.add
			.tileSprite(480, 280, 900, 220, "mist")
			.setAlpha(0.28)
			.setTint(this.theme.accent)
			.setDepth(1);

		for (const rune of [
			{ x: 160, y: 150, scale: 0.52 },
			{ x: 820, y: 170, scale: 0.46 },
			{ x: 730, y: 400, scale: 0.38 },
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
		vignette.fillRect(0, 0, 960, 540);

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
			.sprite(812, 382, "runeGlow")
			.setTint(this.theme.accent)
			.setScale(0.7)
			.setAlpha(0.4)
			.setDepth(3);

		this.lever = this.physics.add
			.staticSprite(812, 382, "lever")
			.setDisplaySize(42, 50);

		this.tweens.add({
			targets: this.lever,
			angle: 5,
			duration: 1200,
			yoyo: true,
			repeat: -1,
			ease: "Sine.easeInOut",
		});

		this.add
			.text(812, 428, "Рычаг", {
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
		switch ((this.level - 1) % 5) {
			case 0:
				this.createMazePuzzle();
				break;
			case 1:
				this.createWordSearchPuzzle();
				break;
			case 2:
				this.createRhythmPuzzle();
				break;
			case 3:
				this.createMemoryMatchPuzzle();
				break;
			default:
				this.createPlatformerPuzzle();
				break;
		}
	}

	private createPlatformerPuzzle(): void {
		const platforms = [
			{ x: 300, y: 380, w: 120, h: 20 },
			{ x: 500, y: 300, w: 120, h: 20 },
			{ x: 350, y: 220, w: 100, h: 20 },
			{ x: 650, y: 200, w: 100, h: 20 },
		];
		for (const p of platforms) {
			this.createWall(p.x, p.y, p.w, p.h);
		}

		const crystalPositions = [
			{ x: 300, y: 340 },
			{ x: 500, y: 260 },
			{ x: 350, y: 180 },
			{ x: 650, y: 160 },
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
		const grid = MAZE_GRID;
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
			startX + 13 * cell,
			startY + 13 * cell,
			26,
			26,
			0x22c55e,
			0.85,
		);
		this.add
			.sprite(startX + 13 * cell, startY + 13 * cell, "runeGlow")
			.setTint(0x22c55e)
			.setAlpha(0.55)
			.setScale(0.55)
			.setDepth(7);
		this.add
			.text(startX + 13 * cell, startY + 13 * cell, "Ф", {
				fontFamily: "Arial",
				fontSize: "16px",
				color: "#052e16",
			})
			.setOrigin(0.5);
		this.add
			.text(startX + 13 * cell, startY + 13 * cell + 26, "Финиш", {
				fontFamily: "Arial",
				fontSize: "11px",
				color: "#bbf7d0",
			})
			.setOrigin(0.5);
		const goal = this.add.zone(startX + 13 * cell, startY + 13 * cell, 28, 28);
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
		const rows = [
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
		];
		const cell = 26;
		const startX = 248;
		const startY = 170;
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
		this.add.text(590, 174, "Найди слова:\nЛАБИРИНТ\nПАЗЗЛ\nПЕЩЕРА\nГОРОД", {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#e0f2fe",
			lineSpacing: 8,
		});
	}

	private createRhythmPuzzle(): void {
		this.rhythmRound = 1;
		const colors = [0xff4444, 0x44ff44, 0x4444ff, 0xffff44];
		for (let index = 0; index < 4; index += 1) {
			const x = 300 + index * 110;
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
			const x = 330 + col * 100;
			const y = 238 + row * 86;

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
		const target = ["ЛАБИРИНТ", "ПАЗЗЛ", "ПЕЩЕРА", "ГОРОД"].find(
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
		for (const [index, buttonIndex] of this.rhythmSequence.entries()) {
			this.time.delayedCall(450 + index * 520, () => {
				const button = this.rhythmButtons[buttonIndex];
				button?.setAlpha(1);
				this.time.delayedCall(260, () => button?.setAlpha(0.45));
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
		const player = this.player;
		const nearest = this.interactables.find((item) => {
			const position = this.getObjectPosition(item.object);
			return (
				Phaser.Math.Distance.Between(
					player.x,
					player.y,
					position.x,
					position.y,
				) < 32
			);
		});
		if (!nearest) {
			this.refreshStatus("Подойди вплотную к объекту пазла или рычагу.");
			return;
		}
		nearest.action();
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
		this.scene.start("TownScene");
	}

	private getPuzzleName(): string {
		const names = [
			"Лабиринт",
			"Поиск слов",
			"Ритм/Паттерн",
			"Memory Match",
			"Платформер",
		];
		return names[(this.level - 1) % names.length];
	}

	private getPuzzlePrompt(): string {
		switch ((this.level - 1) % 5) {
			case 0:
				return "Лабиринт: стрелками двигай героя точно, WASD запускает скольжение до стены. Доберись до зелёного финиша; он не двигается.";
			case 1:
				return "Поиск слов: выбери первую и последнюю букву слова прямой линией через E/Space. Синяя линия подскажет выбор.";
			case 2:
				return "Ритм: запоминай последовательность цветных кнопок и повторяй её героем.";
			case 3:
				return "Memory Match: открывай карты героем, ищи пары и жди, если карты не совпали.";
			default:
				return "Платформер: прыгай по парящим островам и собери все кристаллы.";
		}
	}

	private shuffle<T>(items: T[]): T[] {
		const result = [...items];
		for (let index = result.length - 1; index > 0; index -= 1) {
			const swapIndex = Phaser.Math.Between(0, index);
			[result[index], result[swapIndex]] = [result[swapIndex], result[index]];
		}
		return result;
	}
}
