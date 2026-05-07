import Phaser from "phaser";
import { hasSave, loadProgress, resetProgress } from "../game/SaveSystem";
import { addButton, addHelp, addTitle } from "../systems/UiSystem";

export class MenuScene extends Phaser.Scene {
	public constructor() {
		super("MenuScene");
	}

	public create(): void {
		this.cameras.main.setBackgroundColor("#0f172a");
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
