// Rainbow Tower Builder - UI Manager

import { RAINBOW_COLORS, COLOR_NAMES } from "shared/constants";

/** UI管理クラス */
export class UIManager {
	private screenGui: ScreenGui;
	private colorButtons: TextButton[] = [];
	private selectedColorIndex = 0;
	private onColorSelectedCallback?: (colorIndex: number) => void;

	constructor(player: Player) {
		// ScreenGuiを作成
		this.screenGui = new Instance("ScreenGui");
		this.screenGui.Name = "RainbowTowerUI";
		this.screenGui.ResetOnSpawn = false;
		this.screenGui.Parent = player.WaitForChild("PlayerGui");

		this.createColorPalette();
		this.createVictoryUI();
	}

	/** カラーパレットを作成 */
	private createColorPalette(): void {
		const paletteFrame = new Instance("Frame");
		paletteFrame.Name = "ColorPalette";
		paletteFrame.Size = new UDim2(0, 100, 0, 500);
		paletteFrame.Position = new UDim2(0, 20, 0.5, -250);
		paletteFrame.BackgroundTransparency = 1;
		paletteFrame.Parent = this.screenGui;

		// 各色のボタンを作成
		for (let i = 0; i < RAINBOW_COLORS.size(); i++) {
			const button = new Instance("TextButton");
			button.Name = `ColorButton_${i}`;
			button.Size = new UDim2(1, 0, 0, 50);
			button.Position = new UDim2(0, 0, 0, i * 55);
			button.BackgroundColor3 = RAINBOW_COLORS[i];
			button.BorderSizePixel = 2;
			button.BorderColor3 = new Color3(1, 1, 1);
			button.Text = COLOR_NAMES[i];
			button.TextColor3 = new Color3(0, 0, 0);
			button.TextSize = 18;
			button.Font = Enum.Font.SourceSansBold;
			button.Parent = paletteFrame;

			// クリックイベント
			button.MouseButton1Click.Connect(() => {
				this.selectColor(i);
			});

			this.colorButtons.push(button);
		}

		// 初期選択（赤）
		this.selectColor(0);
	}

	/** 色を選択 */
	selectColor(colorIndex: number): void {
		this.selectedColorIndex = colorIndex;

		// すべてのボタンの枠線をリセット
		for (let i = 0; i < this.colorButtons.size(); i++) {
			this.colorButtons[i].BorderSizePixel = 2;
			this.colorButtons[i].BorderColor3 = new Color3(1, 1, 1);
		}

		// 選択されたボタンを強調
		this.colorButtons[colorIndex].BorderSizePixel = 4;
		this.colorButtons[colorIndex].BorderColor3 = new Color3(1, 1, 1);

		print(`[UI] Selected color: ${COLOR_NAMES[colorIndex]} (index: ${colorIndex})`);

		// コールバック呼び出し
		if (this.onColorSelectedCallback) {
			this.onColorSelectedCallback(colorIndex);
		}
	}

	/** 選択中の色を取得 */
	getSelectedColorIndex(): number {
		return this.selectedColorIndex;
	}

	/** 色選択時のコールバックを設定 */
	onColorSelected(callback: (colorIndex: number) => void): void {
		this.onColorSelectedCallback = callback;
	}

	/** 勝利UI（非表示状態で作成） */
	private createVictoryUI(): void {
		const victoryLabel = new Instance("TextLabel");
		victoryLabel.Name = "VictoryLabel";
		victoryLabel.Size = new UDim2(0, 600, 0, 100);
		victoryLabel.Position = new UDim2(0.5, -300, 0.5, -50);
		victoryLabel.BackgroundColor3 = new Color3(0, 0, 0);
		victoryLabel.BackgroundTransparency = 0.3;
		victoryLabel.BorderSizePixel = 0;
		victoryLabel.Text = "🌈 虹タワー完成！おめでとう！ 🌈";
		victoryLabel.TextColor3 = new Color3(1, 1, 1);
		victoryLabel.TextSize = 36;
		victoryLabel.Font = Enum.Font.SourceSansBold;
		victoryLabel.Visible = false;
		victoryLabel.Parent = this.screenGui;
	}

	/** 勝利演出を表示 */
	showVictory(): void {
		const victoryLabel = this.screenGui.FindFirstChild("VictoryLabel") as TextLabel;
		if (victoryLabel) {
			victoryLabel.Visible = true;

			// 5秒後に非表示
			task.wait(5);
			victoryLabel.Visible = false;
		}
	}
}
