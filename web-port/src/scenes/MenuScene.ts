import Phaser from "phaser";
import { hasSave, loadProgress, resetProgress } from "../game/SaveSystem";
import { addButton, addHelp, addTitle } from "../systems/UiSystem";

export class MenuScene extends Phaser.Scene {
	public constructor() {
		super("MenuScene");
	}

	public create(): void {
		this.cameras.main.setBackgroundColor("#0f172a");
		this.add.image(480, 270, "caveBackground").setAlpha(0.35).setTint(0x312e81);
		this.add
			.sprite(480, 196, "magicCircle")
			.setTint(0xa78bfa)
			.setScale(3.2)
			.setAlpha(0.13);
		for (const item of [
			{ x: 180, y: 82, scale: 0.72 },
			{ x: 740, y: 92, scale: 0.62 },
		]) {
			this.add
				.sprite(item.x, item.y, "softCloud")
				.setScale(item.scale)
				.setAlpha(0.22);
		}
		for (const item of [
			{ x: 160, y: 120, scale: 0.8 },
			{ x: 800, y: 120, scale: 0.8 },
			{ x: 240, y: 420, scale: 0.65 },
			{ x: 720, y: 420, scale: 0.65 },
		]) {
			this.add
				.sprite(item.x, item.y, "moonLantern")
				.setScale(item.scale)
				.setAlpha(0.72);
		}

		addTitle(this, "Adventure Puzzle Game", 110);
		this.add
			.text(480, 155, "Web-port без GameMaker", {
				fontFamily: "Arial",
				fontSize: "20px",
				color: "#cbd5e1",
			})
			.setOrigin(0.5);

		addButton(this, 480, 230, "Новая игра", () => {
			resetProgress();
			this.scene.start("TownScene");
		});

		addButton(
			this,
			480,
			295,
			hasSave() ? "Продолжить" : "Продолжить (нет сохранения)",
			() => {
				loadProgress();
				this.scene.start("TownScene");
			},
		);

		addButton(this, 480, 360, "Как вставить свои спрайты", () => {
			this.scene.start("SpriteHelpScene");
		});

		addHelp(
			this,
			"Управление: WASD/стрелки — движение, E/Space — действие, Esc — назад",
		);
	}
}
