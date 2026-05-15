import Phaser from "phaser";
import { LEVEL_COUNT } from "../game/constants";
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
	private readonly interactables: Interactable[] = [];
	private readonly autoZones: AutoZone[] = [];
	private solids?: Phaser.Physics.Arcade.StaticGroup;
	private dialogue?: DialogueSystem;
	private statusText?: Phaser.GameObjects.Text;

	public constructor() {
		super("TownScene");
	}

	public create(): void {
		const progress = loadProgress();
		if (isExpeditionComplete(progress)) {
			this.scene.start("VictoryScene");
			return;
		}

		this.cameras.main.setBackgroundColor("#16301f");
		this.add.image(480, 270, "townBackground").setAlpha(0.6);
		this.add
			.tileSprite(480, 270, 960, 540, "tileFloor")
			.setAlpha(0.15)
			.setTint(0x166534);

		this.interactables.length = 0;
		this.autoZones.length = 0;
		this.solids = this.physics.add.staticGroup();

		// Основная панель города
		const hasNineSlice = "nineslice" in this.add;
		let mainPanel: Phaser.GameObjects.GameObject;

		if (hasNineSlice) {
			mainPanel = (this.add as any).nineslice(
				480,
				270,
				"uiPanel",
				undefined,
				900,
				470,
				20,
				20,
				20,
				20,
			);
			(mainPanel as any).setAlpha(0.85);
		} else {
			mainPanel = this.add
				.rectangle(480, 270, 900, 470, 0x1f5130, 0.85)
				.setStrokeStyle(3, 0x5fa36f);
		}

		this.add.text(32, 24, "Город-хаб", {
			fontFamily: "Arial",
			fontSize: "28px",
			color: "#f8fafc",
		});

		this.dialogue = new DialogueSystem(this);
		this.player = this.physics.add
			.sprite(480, 350, "player")
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

		this.createNpc(220, 190, "npcElder", "Староста Иара", () => {
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

		this.createNpc(480, 170, "npcMechanic", "Механик Роан", () => {
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

		this.createNpc(740, 190, "npcArchivist", "Архивариус Тель", () => {
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
			.staticSprite(480, 455, "caveEntrance")
			.setDisplaySize(72, 72);
		this.add
			.sprite(480, 455, "runeGlow")
			.setTint(0x86efac)
			.setScale(1.35)
			.setAlpha(0.35)
			.setDepth(0);
		this.add
			.tileSprite(480, 465, 180, 70, "mist")
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
			.text(480, 500, "Вход в пещеры", {
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
		this.refreshStatus();
		for (const autoZone of this.autoZones) {
			this.physics.add.overlap(this.player, autoZone.body, () =>
				this.triggerAutoZone(autoZone),
			);
		}

		addHelp(
			this,
			"NPC — E/Space. Вход в пещеры работает автоматически: просто зайди в проход. Esc — меню.",
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

		const speed = 180;
		const left = this.cursors.left.isDown || this.wasd.A.isDown;
		const right = this.cursors.right.isDown || this.wasd.D.isDown;
		const up = this.cursors.up.isDown || this.wasd.W.isDown;
		const down = this.cursors.down.isDown || this.wasd.S.isDown;

		this.player.setVelocity(
			(Number(right) - Number(left)) * speed,
			(Number(down) - Number(up)) * speed,
		);

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
	}

	private createTownCollision(): void {
		this.createWall(480, 40, 900, 24);
		this.createWall(480, 510, 900, 24);
		this.createWall(34, 270, 24, 470);
		this.createWall(926, 270, 24, 470);
		this.createWall(350, 250, 130, 28);
		this.createWall(610, 250, 130, 28);
		this.createWall(165, 360, 150, 26);
		this.createWall(795, 360, 150, 26);
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

		const player = this.player;
		const nearest = this.interactables.find((item) => {
			const sprite = item.body as Phaser.Physics.Arcade.Sprite;
			return (
				Phaser.Math.Distance.Between(player.x, player.y, sprite.x, sprite.y) <
				72
			);
		});

		if (nearest) {
			nearest.action();
			return;
		}

		this.dialogue?.show("Подсказка", "Подойди ближе к NPC или входу в пещеру.");
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
}
