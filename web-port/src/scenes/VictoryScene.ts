import Phaser from "phaser";
import { resetProgress } from "../game/SaveSystem";
import { addButton, addPanel, addTitle } from "../systems/UiSystem";

export class VictoryScene extends Phaser.Scene {
	public constructor() {
		super("VictoryScene");
	}

	public create(): void {
		this.cameras.main.setBackgroundColor("#312e81");
		this.add.image(480, 270, "caveBackground").setAlpha(0.42).setTint(0x4c1d95);
		this.add
			.sprite(480, 260, "magicCircle")
			.setTint(0xfef3c7)
			.setScale(4.2)
			.setAlpha(0.16);
		for (const item of [
			{ x: 155, y: 370, scale: 0.8 },
			{ x: 805, y: 370, scale: 0.8 },
		]) {
			this.add
				.sprite(item.x, item.y, "caveCrystalCluster")
				.setTint(0xfef3c7)
				.setScale(item.scale)
				.setAlpha(0.65);
		}
		for (let index = 0; index < 14; index += 1) {
			const sparkle = this.add
				.sprite(
					Phaser.Math.Between(80, 880),
					Phaser.Math.Between(70, 460),
					"starSparkle",
				)
				.setTint(0xfef3c7)
				.setScale(Phaser.Math.FloatBetween(0.45, 0.9))
				.setAlpha(0.28);

			this.tweens.add({
				targets: sparkle,
				alpha: 0.85,
				duration: Phaser.Math.Between(700, 1600),
				yoyo: true,
				repeat: -1,
				ease: "Sine.easeInOut",
			});
		}

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
