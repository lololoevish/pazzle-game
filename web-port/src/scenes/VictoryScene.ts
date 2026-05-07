import Phaser from "phaser";
import { resetProgress } from "../game/SaveSystem";
import { addButton, addPanel, addTitle } from "../systems/UiSystem";

export class VictoryScene extends Phaser.Scene {
	public constructor() {
		super("VictoryScene");
	}

	public create(): void {
		this.cameras.main.setBackgroundColor("#312e81");
		addTitle(this, "Экспедиция завершена", 105);
		addPanel(this, 480, 260, 780, 210);
		this.add.text(
			130,
			195,
			"Ты прошёл 24 пещеры и вернулся в город.\nЭто первый runnable web-port: дальше можно заменить заглушки на свои спрайты, расширить пазлы и добавить музыку.",
			{
				fontFamily: "Arial",
				fontSize: "22px",
				color: "#f8fafc",
				wordWrap: { width: 700 },
				lineSpacing: 8,
			},
		);

		addButton(this, 360, 420, "В меню", () => this.scene.start("MenuScene"));
		addButton(this, 600, 420, "Новая игра", () => {
			resetProgress();
			this.scene.start("TownScene");
		});
	}
}
