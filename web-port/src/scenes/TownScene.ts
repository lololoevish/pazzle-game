import Phaser from "phaser";
import {
	GAME_HEIGHT,
	GAME_WIDTH,
	LEVEL_COUNT,
	PLAYER_CONFIG,
} from "../game/constants";
import {
	getCompletedLevelCount,
	isExpeditionComplete,
} from "../game/GameState";
import { loadProgress, saveProgress } from "../game/SaveSystem";
import { DialogueSystem } from "../systems/DialogueSystem";
import { addHelp } from "../systems/UiSystem";

type Interactable = {
	name: string;
	body: Phaser.GameObjects.GameObject;
	action: () => void;
};

type AutoZone = {
	body: Phaser.GameObjects.GameObject;
	action: () => void;
	triggered: boolean;
};

export class TownScene extends Phaser.Scene {
	private player?: Phaser.Physics.Arcade.Sprite;
	private cursors?: Phaser.Types.Input.Keyboard.CursorKeys;
	private wasd?: Record<string, Phaser.Input.Keyboard.Key>;
	private interactKey?: Phaser.Input.Keyboard.Key;
	private spaceKey?: Phaser.Input.Keyboard.Key;
	private escKey?: Phaser.Input.Keyboard.Key;
	private shiftKey?: Phaser.Input.Keyboard.Key;
	private readonly interactables: Interactable[] = [];
	private readonly autoZones: AutoZone[] = [];
	private solids?: Phaser.Physics.Arcade.StaticGroup;
	private dialogue?: DialogueSystem;
	private statusText?: Phaser.GameObjects.Text;
	private focusRing?: Phaser.GameObjects.Arc;
	private currentMoveX = 0;
	private currentMoveY = 0;
	private isDashing = false;
	private dashCooldown = 0;

	public constructor() {
		super("TownScene");
	}

	public create(): void {
		this.player = undefined;
		this.cursors = undefined;
		this.wasd = undefined;
		this.interactKey = undefined;
		this.spaceKey = undefined;
		this.escKey = undefined;
		this.shiftKey = undefined;
		this.solids = undefined;
		this.dialogue = undefined;
		this.statusText = undefined;
		this.focusRing = undefined;

		const progress = loadProgress();
		if (isExpeditionComplete(progress)) {
			this.scene.start("VictoryScene");
			return;
		}

		this.cameras.main.setBackgroundColor("#16301f");
		this.physics.world.setBounds(0, 0, GAME_WIDTH, GAME_HEIGHT);
		this.add.image(400, 300, "townBackground").setAlpha(0.6);
		this.add
			.tileSprite(400, 300, GAME_WIDTH, GAME_HEIGHT, "tileFloor")
			.setAlpha(0.15)
			.setTint(0x166534);

		this.interactables.length = 0;
		this.autoZones.length = 0;
		this.solids = this.physics.add.staticGroup();
		this.createDecorations();

		// Основная панель города
		const hasNineSlice = "nineslice" in this.add;
		let mainPanel: Phaser.GameObjects.GameObject;

		if (hasNineSlice) {
			mainPanel = (this.add as any).nineslice(
				400,
				300,
				"uiPanel",
				undefined,
				744,
				500,
				20,
				20,
				20,
				20,
			);
			(mainPanel as any).setAlpha(0.85);
		} else {
			mainPanel = this.add
				.rectangle(400, 300, 744, 500, 0x1f5130, 0.85)
				.setStrokeStyle(3, 0x5fa36f);
		}

		this.add.text(32, 24, "Город-хаб", {
			fontFamily: "Arial",
			fontSize: "28px",
			color: "#f8fafc",
		});

		this.dialogue = new DialogueSystem(this);
		this.player = this.physics.add
			.sprite(400, 400, "player")
			.setCollideWorldBounds(true);
		this.player.setDisplaySize(40, 48);

		this.tweens.add({
			targets: this.player,
			scaleY: 0.96,
			duration: 1200,
			yoyo: true,
			repeat: -1,
			ease: "Sine.easeInOut",
		});

		this.createTownCollision();
		this.physics.add.collider(this.player, this.solids);

		this.createNpc(200, 300, "npcElder", "Староста Иара", () => {
			const next = loadProgress();
			if (!next.npcRewards.elder) {
				next.npcRewards.elder = true;
				next.gold += 15;
				saveProgress(next);
			}
			this.dialogue?.show(
				"Староста Иара",
				"Пещеры снова зовут. Я дала тебе 15 золота на дорогу.",
			);
			this.refreshStatus();
		});

		this.createNpc(600, 300, "npcMechanic", "Механик Роан", () => {
			const next = loadProgress();
			if (!next.npcRewards.mechanic) {
				next.npcRewards.mechanic = true;
				next.inventory.push("repair-kit");
				saveProgress(next);
			}
			this.dialogue?.show(
				"Механик Роан",
				"Я подготовил набор инструментов. Он пригодится в глубине пещер.",
			);
			this.refreshStatus();
		});

		this.createNpc(400, 200, "npcArchivist", "Архивариус Тель", () => {
			const next = loadProgress();
			if (!next.npcRewards.archivist) {
				next.npcRewards.archivist = true;
				next.inventory.push("ancient-note");
				saveProgress(next);
			}
			this.dialogue?.show(
				"Архивариус Тель",
				"В записях сказано: каждая пещера хранит рычаг прогресса.",
			);
			this.refreshStatus();
		});

		const entrance = this.physics.add
			.staticSprite(400, 505, "caveEntrance")
			.setDisplaySize(72, 72);
		this.add
			.sprite(400, 505, "runeGlow")
			.setTint(0x86efac)
			.setScale(1.35)
			.setAlpha(0.35)
			.setDepth(0);
		this.add
			.tileSprite(400, 515, 180, 70, "mist")
			.setTint(0xbbf7d0)
			.setAlpha(0.22)
			.setDepth(1);
		this.autoZones.push({
			body: entrance,
			action: () =>
				this.scene.start("CaveScene", { level: loadProgress().currentLevel }),
			triggered: false,
		});
		this.add
			.text(400, 558, "Вход в пещеры", {
				fontFamily: "Arial",
				fontSize: "16px",
				color: "#f8fafc",
			})
			.setOrigin(0.5);

		this.statusText = this.add.text(32, 64, "", {
			fontFamily: "Arial",
			fontSize: "18px",
			color: "#e5e7eb",
		});
		this.focusRing = this.add
			.circle(0, 0, 40)
			.setStrokeStyle(3, 0xfde68a, 0.9)
			.setDepth(30)
			.setVisible(false);
		this.refreshStatus();
		for (const autoZone of this.autoZones) {
			this.physics.add.overlap(this.player, autoZone.body, () =>
				this.triggerAutoZone(autoZone),
			);
		}

		addHelp(
			this,
			"WASD/стрелки — движение, Shift — ускорение, NPC — E/Space. Вход в пещеры работает автоматически. Esc — меню.",
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
	}

	public update(_time: number, delta: number): void {
		if (!this.player || !this.cursors || !this.wasd) {
			return;
		}

		if (this.dashCooldown > 0) {
			this.dashCooldown -= delta;
		}

		const dt = Math.min(delta / 1000, 0.05);
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

		if (pressedSpace && !this.isDashing && this.dashCooldown <= 0 && isMoving) {
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
		this.updateInteractableFocus();

		// Мягкий Squash & Stretch для анимации ГГ
		if (isMoving && !this.isDashing) {
			const time = this.time.now;
			const stretchX = 1 + Math.sin(time / 80) * 0.08;
			const stretchY = 1 - Math.sin(time / 80) * 0.08;
			this.player.setScale(stretchX, stretchY);

			// Легкий наклон при движении
			const angle = velocityX * 0.03;
			this.player.setAngle(angle);

			// Спавн пылинок
			if (this.time.now % 6 === 0) {
				this.spawnStepParticle(this.player.x, this.player.y);
			}
		} else if (!this.isDashing) {
			// Мягкое дыхание стоя
			const time = this.time.now;
			const breath = 1 + Math.sin(time / 300) * 0.02;
			this.player.setScale(1, breath);
			this.player.setAngle(0);
		}

		const pressedInteract = this.interactKey
			? Phaser.Input.Keyboard.JustDown(this.interactKey)
			: false;

		if (pressedInteract) {
			this.interact();
		}

		if (this.escKey && Phaser.Input.Keyboard.JustDown(this.escKey)) {
			this.scene.start("MenuScene");
		}
	}

	private createNpc(
		x: number,
		y: number,
		sprite: string,
		name: string,
		action: () => void,
	): void {
		const npc = this.physics.add
			.staticSprite(x, y, sprite)
			.setDisplaySize(44, 52);
		this.add
			.text(x, y + 38, name, {
				fontFamily: "Arial",
				fontSize: "14px",
				color: "#f8fafc",
			})
			.setOrigin(0.5);
		this.interactables.push({ name, body: npc, action });

		const staticBody = npc.body as Phaser.Physics.Arcade.StaticBody;
		staticBody.setCircle(14, 8, 24);
		this.solids?.add(npc);
	}

	private createDecorations(): void {
		for (const item of [
			{ x: 190, y: 76, scale: 0.72, alpha: 0.28 },
			{ x: 520, y: 94, scale: 0.58, alpha: 0.2 },
			{ x: 708, y: 72, scale: 0.66, alpha: 0.24 },
		]) {
			const cloud = this.add
				.sprite(item.x, item.y, "softCloud")
				.setScale(item.scale)
				.setAlpha(item.alpha)
				.setDepth(1);

			this.tweens.add({
				targets: cloud,
				x: cloud.x + 18,
				duration: 6200,
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});
		}

		for (const item of [
			{ x: 235, y: 384, scaleX: 1.65, scaleY: 0.72, angle: -4 },
			{ x: 400, y: 430, scaleX: 1.9, scaleY: 0.78, angle: 0 },
			{ x: 565, y: 384, scaleX: 1.65, scaleY: 0.72, angle: 4 },
		]) {
			this.add
				.sprite(item.x, item.y, "townPath")
				.setScale(item.scaleX, item.scaleY)
				.setAngle(item.angle)
				.setAlpha(0.36)
				.setDepth(1);
		}

		for (const item of [
			{ x: 210, y: 92, scale: 0.8, tint: 0xc4b5fd },
			{ x: 590, y: 92, scale: 0.8, tint: 0xfde68a },
		]) {
			const banner = this.add
				.sprite(item.x, item.y, "townBanner")
				.setTint(item.tint)
				.setScale(item.scale)
				.setAlpha(0.82)
				.setDepth(2);

			this.tweens.add({
				targets: banner,
				y: banner.y + 4,
				duration: 1700,
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});
		}

		for (const item of [
			{ x: 96, y: 92, scale: 0.72 },
			{ x: 704, y: 92, scale: 0.72 },
			{ x: 96, y: 500, scale: 0.62 },
			{ x: 704, y: 500, scale: 0.62 },
		]) {
			const lantern = this.add
				.sprite(item.x, item.y, "moonLantern")
				.setScale(item.scale)
				.setAlpha(0.78)
				.setDepth(3);

			this.tweens.add({
				targets: lantern,
				alpha: 1,
				scale: item.scale * 1.06,
				duration: 1200,
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});
		}

		for (const item of [
			{ x: 200, y: 314, scale: 0.55 },
			{ x: 400, y: 214, scale: 0.55 },
			{ x: 600, y: 314, scale: 0.55 },
			{ x: 400, y: 505, scale: 1.05 },
		]) {
			this.add
				.sprite(item.x, item.y, "magicCircle")
				.setScale(item.scale)
				.setTint(0xa7f3d0)
				.setAlpha(0.16)
				.setDepth(1);
		}

		const grass = [
			{ x: 138, y: 132, scale: 0.9 },
			{ x: 292, y: 408, scale: 1.1 },
			{ x: 620, y: 455, scale: 1 },
			{ x: 708, y: 128, scale: 0.8 },
			{ x: 432, y: 248, scale: 0.7 },
		];
		for (const item of grass) {
			this.add
				.sprite(item.x, item.y, "grassPatch")
				.setScale(item.scale)
				.setAlpha(0.75)
				.setDepth(2);
		}

		const pebbles = [
			{ x: 188, y: 422, tint: 0x94a3b8 },
			{ x: 392, y: 308, tint: 0x64748b },
			{ x: 584, y: 316, tint: 0x94a3b8 },
			{ x: 692, y: 470, tint: 0x64748b },
		];
		for (const item of pebbles) {
			this.add
				.sprite(item.x, item.y, "stonePebble")
				.setTint(item.tint)
				.setAlpha(0.55)
				.setDepth(2);
		}

		for (const x of [200, 400, 600]) {
			this.add
				.sprite(x, 136, "starSparkle")
				.setTint(0xfef3c7)
				.setAlpha(0.35)
				.setScale(0.6)
				.setDepth(3);
		}
	}

	private createTownCollision(): void {
		this.createWall(400, 40, 744, 24);
		this.createWall(400, 570, 744, 24);
		this.createWall(34, 300, 24, 500);
		this.createWall(766, 300, 24, 500);
		this.createWall(310, 255, 120, 24);
		this.createWall(490, 255, 120, 24);
		this.createWall(145, 392, 120, 24);
		this.createWall(655, 392, 120, 24);
	}

	private approach(current: number, target: number, amount: number): number {
		if (current < target) return Math.min(current + amount, target);
		if (current > target) return Math.max(current - amount, target);
		return target;
	}

	private createWall(
		x: number,
		y: number,
		width: number,
		height: number,
	): void {
		const wall = this.add
			.rectangle(x, y, width, height, 0x0f2a1a, 0.9)
			.setStrokeStyle(1, 0x5fa36f);
		this.physics.add.existing(wall, true);
		this.solids?.add(wall);
	}

	private interact(): void {
		if (this.dialogue?.isVisible) {
			this.dialogue.hide();
			return;
		}
		if (!this.player) {
			return;
		}

		const nearest = this.getNearestInteractable(72);

		if (nearest) {
			nearest.action();
			return;
		}

		this.dialogue?.show("Подсказка", "Подойди ближе к NPC или входу в пещеру.");
	}

	private getNearestInteractable(
		maxDistance: number,
	): Interactable | undefined {
		if (!this.player) return undefined;
		let nearest: Interactable | undefined;
		let nearestDistance = maxDistance;

		for (const item of this.interactables) {
			const sprite = item.body as Phaser.Physics.Arcade.Sprite;
			const distance = Phaser.Math.Distance.Between(
				this.player.x,
				this.player.y,
				sprite.x,
				sprite.y,
			);
			if (distance < nearestDistance) {
				nearest = item;
				nearestDistance = distance;
			}
		}

		return nearest;
	}

	private updateInteractableFocus(): void {
		const nearest = this.getNearestInteractable(96);
		if (!nearest || !this.focusRing) {
			this.focusRing?.setVisible(false);
			return;
		}
		const sprite = nearest.body as Phaser.Physics.Arcade.Sprite;
		this.focusRing
			.setPosition(sprite.x, sprite.y)
			.setVisible(true)
			.setAlpha(0.65 + Math.sin(this.time.now / 140) * 0.25);
	}

	private refreshStatus(): void {
		const progress = loadProgress();
		const npcCount = Object.values(progress.npcRewards).filter(Boolean).length;
		this.statusText?.setText(
			`Прогресс: ${getCompletedLevelCount(progress)}/${LEVEL_COUNT} | Текущая пещера: ${progress.currentLevel} | Золото: ${progress.gold} | NPC: ${npcCount}/3`,
		);
	}

	private triggerAutoZone(autoZone: AutoZone): void {
		if (autoZone.triggered) {
			return;
		}
		autoZone.triggered = true;
		autoZone.action();
	}

	private spawnStepParticle(x: number, y: number): void {
		const size = Phaser.Math.Between(2, 4);
		const dust = this.add.rectangle(
			x + Phaser.Math.Between(-8, 8),
			y + 20,
			size,
			size,
			0x5fa36f, // Зеленоватая пыль для травы хаба
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
			.setTint(0x38bdf8)
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
