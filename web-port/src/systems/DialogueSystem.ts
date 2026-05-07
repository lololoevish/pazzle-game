import type Phaser from "phaser";
import { addPanel } from "./UiSystem";

export class DialogueSystem {
	private readonly scene: Phaser.Scene;
	private panel?: Phaser.GameObjects.Rectangle;
	private text?: Phaser.GameObjects.Text;

	public constructor(scene: Phaser.Scene) {
		this.scene = scene;
	}

	public show(speaker: string, message: string): void {
		this.hide();
		this.panel = addPanel(this.scene, 480, 430, 860, 130);
		this.text = this.scene.add.text(80, 378, `${speaker}\n${message}`, {
			fontFamily: "Arial",
			fontSize: "20px",
			color: "#f8fafc",
			wordWrap: { width: 800 },
			lineSpacing: 6,
		});
	}

	public hide(): void {
		this.panel?.destroy();
		this.text?.destroy();
		this.panel = undefined;
		this.text = undefined;
	}
}
