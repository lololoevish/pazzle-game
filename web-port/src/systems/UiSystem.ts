import type Phaser from "phaser";
import { GAME_HEIGHT, GAME_WIDTH } from "../game/constants";

export function addTitle(
	scene: Phaser.Scene,
	text: string,
	y = 48,
): Phaser.GameObjects.Text {
	return scene.add
		.text(GAME_WIDTH / 2, y, text, {
			fontFamily: "Arial",
			fontSize: "34px",
			color: "#f8fafc",
			align: "center",
		})
		.setOrigin(0.5);
}

export function addPanel(
	scene: Phaser.Scene,
	x: number,
	y: number,
	width: number,
	height: number,
): Phaser.GameObjects.Rectangle {
	return scene.add
		.rectangle(x, y, width, height, 0x111827, 0.82)
		.setStrokeStyle(2, 0x334155);
}

export function addButton(
	scene: Phaser.Scene,
	x: number,
	y: number,
	label: string,
	onClick: () => void,
): Phaser.GameObjects.Text {
	const button = scene.add
		.text(x, y, label, {
			fontFamily: "Arial",
			fontSize: "24px",
			color: "#e5e7eb",
			backgroundColor: "#1f2937",
			padding: { x: 18, y: 10 },
		})
		.setOrigin(0.5)
		.setInteractive({ useHandCursor: true });

	button.on("pointerover", () =>
		button.setStyle({ color: "#ffffff", backgroundColor: "#334155" }),
	);
	button.on("pointerout", () =>
		button.setStyle({ color: "#e5e7eb", backgroundColor: "#1f2937" }),
	);
	button.on("pointerdown", onClick);

	return button;
}

export function addHelp(
	scene: Phaser.Scene,
	text: string,
): Phaser.GameObjects.Text {
	return scene.add.text(24, GAME_HEIGHT - 44, text, {
		fontFamily: "Arial",
		fontSize: "16px",
		color: "#cbd5e1",
	});
}
