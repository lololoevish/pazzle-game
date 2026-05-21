import Phaser from "phaser";
import { GAME_HEIGHT, GAME_WIDTH, PLAYER_CONFIG } from "../game/constants";

type TransitionData = {
	fromLevel: number;
	toLevel: number;
};

export class TransitionScene extends Phaser.Scene {
	private toLevel = 2;
	private player?: Phaser.Physics.Arcade.Sprite;
	private cursors?: Phaser.Types.Input.Keyboard.CursorKeys;
	private wasd?: Record<string, Phaser.Input.Keyboard.Key>;
	private spaceKey?: Phaser.Input.Keyboard.Key;
	private escKey?: Phaser.Input.Keyboard.Key;
	private shiftKey?: Phaser.Input.Keyboard.Key;
	private solids?: Phaser.Physics.Arcade.StaticGroup;
	private jumpCount = 0;
	private coyoteTimer = 0;
	private jumpBufferTimer = 0;

	public constructor() {
		super("TransitionScene");
	}

	public init(data: TransitionData): void {
		this.toLevel = Number(data.toLevel) || 2;
		this.jumpCount = 0;
		this.player = undefined;
		this.cursors = undefined;
		this.wasd = undefined;
		this.spaceKey = undefined;
		this.escKey = undefined;
		this.shiftKey = undefined;
		this.solids = undefined;
	}

	public create(): void {
		this.cameras.main.setBackgroundColor("#020617");

		// Расширяем границы мира для огромной пещеры (2500px в ширину)
		const WORLD_WIDTH = 2500;
		this.physics.world.setBounds(0, 0, WORLD_WIDTH, GAME_HEIGHT);
		this.cameras.main.setBounds(0, 0, WORLD_WIDTH, GAME_HEIGHT);

		// Фон (повторяющийся)
		for (let i = 0; i < 4; i++) {
			this.add
				.image(
					GAME_WIDTH / 2 + i * GAME_WIDTH,
					GAME_HEIGHT / 2,
					"caveBackground",
				)
				.setAlpha(0.25)
				.setTint(0x475569);
		}

		// Золотая окантовка внешних границ
		this.add
			.rectangle(
				WORLD_WIDTH / 2,
				GAME_HEIGHT / 2,
				WORLD_WIDTH - 20,
				GAME_HEIGHT - 20,
				0x000000,
				0,
			)
			.setStrokeStyle(3, 0xfacc15, 0.4)
			.setScrollFactor(0);

		// Тексты инструкций (фиксированные на экране)
		this.add
			.text(GAME_WIDTH / 2, 60, "ПРОХОД МЕЖДУ ПЕЩЕРАМИ", {
				fontFamily: "Arial Black",
				fontSize: "26px",
				color: "#fbbf24",
			})
			.setOrigin(0.5)
			.setScrollFactor(0);

		this.add
			.text(
				GAME_WIDTH / 2,
				100,
				`Пройди три секции паркура до Пещеры ${this.toLevel} ИЛИ вернись в деревню.`,
				{
					fontFamily: "Arial",
					fontSize: "16px",
					color: "#94a3b8",
				},
			)
			.setOrigin(0.5)
			.setScrollFactor(0);

		// Создаем физические платформы
		this.solids = this.physics.add.staticGroup();

		// Декоративные элементы для атмосферы
		// Кристаллы в секции 1
		this.add
			.image(300, 500, "caveCrystalCluster")
			.setAlpha(0.6)
			.setTint(0x60a5fa);
		this.add
			.image(450, 420, "caveCrystalCluster")
			.setAlpha(0.5)
			.setTint(0x3b82f6);

		// Светящиеся грибы в секции 2
		this.add.image(1000, 380, "glowMushroom").setAlpha(0.7).setTint(0x34d399);
		this.add.image(1200, 360, "glowMushroom").setAlpha(0.6).setTint(0x10b981);
		this.add.image(1350, 380, "glowMushroom").setAlpha(0.7).setTint(0x34d399);

		// Туман в секции 3
		this.add.image(1700, 450, "mist").setAlpha(0.3).setScale(2);
		this.add.image(1950, 470, "mist").setAlpha(0.25).setScale(2.5);
		this.add.image(2200, 480, "mist").setAlpha(0.3).setScale(2);

		// === СЕКЦИЯ 1: ПРЫЖКИ ВВЕРХ (Лестница) ===
		// Стартовая платформа
		this.createPlatform(100, 500, 160, 24);
		this.add
			.text(100, 460, "Старт", {
				fontFamily: "Arial",
				fontSize: "14px",
				color: "#cbd5e1",
			})
			.setOrigin(0.5);

		// Лестница вверх
		this.createPlatform(220, 460, 80, 20);
		this.createPlatform(320, 420, 80, 20);
		this.createPlatform(420, 380, 80, 20);
		this.createPlatform(520, 340, 80, 20);
		this.createPlatform(620, 300, 100, 20);

		this.add
			.text(670, 270, "Секция 1", {
				fontFamily: "Arial Black",
				fontSize: "12px",
				color: "#60a5fa",
			})
			.setOrigin(0.5);

		// === СЕКЦИЯ 2: ДЛИННЫЕ ПРЫЖКИ (Пропасти) ===
		// Переход на вторую секцию
		this.createPlatform(750, 300, 60, 20);

		// Длинные прыжки через пропасти
		this.createPlatform(900, 320, 70, 20);
		this.createPlatform(1080, 300, 70, 20);
		this.createPlatform(1260, 320, 70, 20);
		this.createPlatform(1440, 300, 80, 20);

		this.add
			.text(1480, 270, "Секция 2", {
				fontFamily: "Arial Black",
				fontSize: "12px",
				color: "#34d399",
			})
			.setOrigin(0.5);

		// === СЕКЦИЯ 3: ТОЧНЫЕ ПРЫЖКИ (Узкие платформы) ===
		// Переход на третью секцию
		this.createPlatform(1580, 300, 60, 20);

		// Узкие платформы на разной высоте
		this.createPlatform(1680, 360, 50, 20);
		this.createPlatform(1780, 320, 50, 20);
		this.createPlatform(1880, 380, 50, 20);
		this.createPlatform(1980, 340, 50, 20);
		this.createPlatform(2080, 400, 50, 20);
		this.createPlatform(2180, 360, 50, 20);

		// Финишная платформа
		this.createPlatform(2300, 420, 140, 24);

		this.add
			.text(2370, 390, "Секция 3", {
				fontFamily: "Arial Black",
				fontSize: "12px",
				color: "#f59e0b",
			})
			.setOrigin(0.5);

		// Дверь в деревню (слева, рядом со спавном игрока)
		const townDoor = this.physics.add
			.staticSprite(80, 380, "runeGlow")
			.setDisplaySize(48, 48)
			.setTint(0xf87171);
		this.add
			.text(80, 334, "В деревню", {
				fontFamily: "Arial Black",
				fontSize: "13px",
				color: "#f87171",
			})
			.setOrigin(0.5);

		// Портал в следующую пещеру (в конце третьей секции)
		const nextPortal = this.physics.add
			.staticSprite(2370, 356, "caveEntrance")
			.setDisplaySize(64, 64);
		this.add
			.text(2370, 310, `Пещера ${this.toLevel}`, {
				fontFamily: "Arial Black",
				fontSize: "14px",
				color: "#34d399",
			})
			.setOrigin(0.5);

		// Спавн игрока (слева)
		this.player = this.physics.add
			.sprite(80, 440, "player")
			.setCollideWorldBounds(true);
		this.player.setDisplaySize(36, 44).setDepth(20);

		// Камера следует за игроком
		this.cameras.main.startFollow(this.player, true, 0.1, 0.1);

		// Коллизии со стенами/платформами
		this.physics.add.collider(this.player, this.solids);

		// Триггеры переходов
		this.physics.add.overlap(this.player, nextPortal, () => {
			this.scene.start("CaveScene", { level: this.toLevel });
		});

		this.physics.add.overlap(this.player, townDoor, () => {
			this.scene.start("TownScene");
		});

		// Настройка управления
		this.cursors = this.input.keyboard?.createCursorKeys();
		this.wasd = this.input.keyboard?.addKeys("W,A,S,D") as Record<
			string,
			Phaser.Input.Keyboard.Key
		>;
		this.spaceKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.SPACE,
		);
		this.escKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.ESC,
		);
		this.shiftKey = this.input.keyboard?.addKey(
			Phaser.Input.Keyboard.KeyCodes.SHIFT,
		);
	}

	public update(_time: number, delta: number): void {
		if (!this.player || !this.cursors || !this.wasd) return;

		const dt = Math.min(delta / 1000, 0.05);

		const body = this.player.body as Phaser.Physics.Arcade.Body | undefined;
		if (!body) return;

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
		const onGround = Boolean(body.blocked.down || body.touching.down);

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
			body.velocity.x,
			targetVelocity,
			(inputX === 0 ? decel : accel) * dt,
		);

		this.player.setVelocityX(nextVelocityX);

		// Прыжок
		if (this.jumpBufferTimer > 0 && (onGround || this.coyoteTimer > 0)) {
			this.player.setVelocityY(-PLAYER_CONFIG.jumpSpeed);
			this.jumpBufferTimer = 0;
			this.coyoteTimer = 0;
			this.jumpCount = 1;
			this.player.setScale(0.8, 1.25);
			this.spawnStepParticle(this.player.x, this.player.y);
		}
		// Двойной прыжок
		else if (jumpPressed && !onGround && this.jumpCount < 2) {
			this.player.setVelocityY(-PLAYER_CONFIG.jumpSpeed * 0.9);
			this.jumpBufferTimer = 0;
			this.jumpCount = 2;
			this.player.setScale(1.25, 0.75);
			this.cameras.main.shake(85, 0.003);
			for (let i = 0; i < 6; i++) {
				this.spawnStepParticle(this.player.x, this.player.y);
			}
		}

		if (jumpReleased && body.velocity.y < -PLAYER_CONFIG.jumpCutSpeed) {
			this.player.setVelocityY(-PLAYER_CONFIG.jumpCutSpeed);
		}

		const gravity =
			body.velocity.y < 0
				? jumpDown
					? PLAYER_CONFIG.gravityRiseHold
					: PLAYER_CONFIG.gravityRiseRelease
				: PLAYER_CONFIG.gravityFall;
		this.player.setGravityY(gravity);

		// Анимационные покачивания
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
				const time = this.time.now;
				this.player.setScale(1, 1 + Math.sin(time / 300) * 0.02);
				this.player.setAngle(0);
			}
		} else {
			this.player.setAngle(nextVelocityX * 0.045);
		}

		// Респавн при падении
		if (this.player.y > 560) {
			this.player.setPosition(80, 440);
			this.player.setVelocity(0, 0);
			this.cameras.main.shake(150, 0.006);
		}

		if (this.escKey && Phaser.Input.Keyboard.JustDown(this.escKey)) {
			this.scene.start("TownScene");
		}
	}

	private createPlatform(
		x: number,
		y: number,
		width: number,
		height: number,
	): void {
		const platform = this.add
			.tileSprite(x, y, width, height, "caveWall")
			.setTint(0x475569)
			.setDepth(2);
		this.physics.add.existing(platform, true);
		this.solids?.add(platform);
	}

	private approach(current: number, target: number, amount: number): number {
		if (current < target) return Math.min(current + amount, target);
		if (current > target) return Math.max(current - amount, target);
		return target;
	}

	private spawnStepParticle(x: number, y: number): void {
		const size = Phaser.Math.Between(2, 4);
		const dust = this.add.rectangle(
			x + Phaser.Math.Between(-8, 8),
			y + 20,
			size,
			size,
			0x64748b,
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
}
