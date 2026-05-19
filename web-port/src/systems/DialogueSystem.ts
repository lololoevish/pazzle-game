import type Phaser from "phaser";
import { GAME_HEIGHT, GAME_WIDTH } from "../game/constants";

type SpeakerInfo = { color: number; letter: string };

function getSpeakerInfo(speaker: string): SpeakerInfo {
	switch (speaker) {
		case "Староста Иара":
			return { color: 0xffd37a, letter: "И" };
		case "Механик Роан":
			return { color: 0x9cff8f, letter: "Р" };
		case "Архивариус Тель":
			return { color: 0xd8a3ff, letter: "Т" };
		case "Подсказка":
			return { color: 0x7dd3fc, letter: "?" };
		default:
			return { color: 0x94a3b8, letter: "!" };
	}
}

export class DialogueSystem {
	private readonly scene: Phaser.Scene;
	private panel?: Phaser.GameObjects.GameObject;
	private portrait?: Phaser.GameObjects.Rectangle;
	private portraitLetter?: Phaser.GameObjects.Text;
	private speakerText?: Phaser.GameObjects.Text;
	private messageText?: Phaser.GameObjects.Text;
	private hintText?: Phaser.GameObjects.Text;
	private clickZone?: Phaser.GameObjects.Zone;
	private typewriterEvent?: Phaser.Time.TimerEvent;
	private fullMessage = "";
	private charIndex = 0;
	private typing = false;

	public constructor(scene: Phaser.Scene) {
		this.scene = scene;
	}

	public get isVisible(): boolean {
		return this.panel !== undefined;
	}

	public show(speaker: string, message: string): void {
		this.hide();

		const info = getSpeakerInfo(speaker);
		this.fullMessage = message;
		this.charIndex = 0;
		this.typing = true;

		// Панель диалога
		let panelObj: Phaser.GameObjects.GameObject;
		if ("nineslice" in this.scene.add) {
			panelObj = (this.scene.add as any).nineslice(
				GAME_WIDTH / 2,
				GAME_HEIGHT - 108,
				"uiPanel",
				undefined,
				GAME_WIDTH - 64,
				130,
				20,
				20,
				20,
				20,
			);
			(panelObj as any).setDepth(50);
		} else {
			panelObj = (this.scene.add as any)
				.rectangle(
					GAME_WIDTH / 2,
					GAME_HEIGHT - 108,
					GAME_WIDTH - 64,
					130,
					0x111827,
				)
				.setAlpha(0.9)
				.setStrokeStyle(1, 0x334155)
				.setDepth(50);
		}
		this.panel = panelObj;

		// Портрет-прямоугольник
		this.portrait = this.scene.add
			.rectangle(70, GAME_HEIGHT - 108, 76, 90, info.color)
			.setStrokeStyle(2, 0xffffff)
			.setDepth(51);

		// Буква в центре портрета
		this.portraitLetter = this.scene.add
			.text(70, GAME_HEIGHT - 108, info.letter, {
				fontFamily: "Arial Black",
				fontSize: "28px",
				color: "#0f172a",
			})
			.setOrigin(0.5)
			.setDepth(52);

		// Имя говорящего
		this.speakerText = this.scene.add
			.text(122, GAME_HEIGHT - 154, speaker, {
				fontFamily: "Arial",
				fontSize: "16px",
				fontStyle: "bold",
				color: "#93c5fd",
			})
			.setDepth(51);

		// Текст сообщения (пустой — заполняется typewriter'ом)
		this.messageText = this.scene.add
			.text(122, GAME_HEIGHT - 132, "", {
				fontFamily: "Arial",
				fontSize: "18px",
				color: "#f8fafc",
				wordWrap: { width: GAME_WIDTH - 210 },
			})
			.setDepth(51);

		// Подсказка
		this.hintText = this.scene.add
			.text(GAME_WIDTH - 40, GAME_HEIGHT - 49, "[клик — продолжить]", {
				fontFamily: "Arial",
				fontSize: "13px",
				color: "#475569",
			})
			.setOrigin(1, 1)
			.setDepth(51);

		// Невидимая зона клика
		this.clickZone = this.scene.add
			.zone(GAME_WIDTH / 2, GAME_HEIGHT - 108, GAME_WIDTH - 64, 130)
			.setInteractive()
			.setDepth(53);

		this.clickZone.on("pointerdown", () => {
			this.handleClick();
		});

		this.startTypewriter();
	}

	public hide(): void {
		this.typewriterEvent?.remove(false);
		this.typewriterEvent = undefined;

		this.panel?.destroy();
		this.portrait?.destroy();
		this.portraitLetter?.destroy();
		this.speakerText?.destroy();
		this.messageText?.destroy();
		this.hintText?.destroy();
		this.clickZone?.destroy();

		this.panel = undefined;
		this.portrait = undefined;
		this.portraitLetter = undefined;
		this.speakerText = undefined;
		this.messageText = undefined;
		this.hintText = undefined;
		this.clickZone = undefined;

		this.typing = false;
		this.fullMessage = "";
		this.charIndex = 0;
	}

	private startTypewriter(): void {
		this.typewriterEvent = this.scene.time.addEvent({
			delay: 28,
			callback: () => {
				this.typeNextChar();
			},
			loop: true,
		});
	}

	private typeNextChar(): void {
		if (!this.messageText) {
			return;
		}

		if (this.charIndex < this.fullMessage.length) {
			this.charIndex++;
			this.messageText.setText(this.fullMessage.slice(0, this.charIndex));
		} else {
			this.typewriterEvent?.remove(false);
			this.typewriterEvent = undefined;
			this.typing = false;
		}
	}

	private handleClick(): void {
		if (this.typing) {
			// Показать весь текст немедленно
			this.typewriterEvent?.remove(false);
			this.typewriterEvent = undefined;
			this.typing = false;
			this.charIndex = this.fullMessage.length;
			this.messageText?.setText(this.fullMessage);
		} else {
			// Закрыть диалог
			this.hide();
		}
	}
}
