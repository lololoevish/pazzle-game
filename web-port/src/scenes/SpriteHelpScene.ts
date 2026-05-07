import Phaser from "phaser";
import { addButton, addPanel, addTitle } from "../systems/UiSystem";

export class SpriteHelpScene extends Phaser.Scene {
	public constructor() {
		super("SpriteHelpScene");
	}

	public create(): void {
		this.cameras.main.setBackgroundColor("#111827");
		addTitle(this, "Свои спрайты", 64);
		addPanel(this, 480, 260, 850, 300);
		this.add.text(
			90,
			145,
			[
				"1. Положи PNG в web-port/public/sprites/",
				"2. Открой web-port/public/sprites/manifest.json",
				"3. Пропиши файл напротив нужного ключа, например:",
				'   "player": "my-player.png"',
				"4. Обнови страницу. Если файл не найден — будет заглушка.",
				"",
				"Ключи: player, npcElder, npcMechanic, npcArchivist, lever, caveEntrance, crystal.",
			].join("\n"),
			{
				fontFamily: "Arial",
				fontSize: "20px",
				color: "#e5e7eb",
				lineSpacing: 8,
			},
		);

		addButton(this, 480, 455, "Назад", () => this.scene.start("MenuScene"));
	}
}
