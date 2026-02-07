// Rainbow Cube - UI Manager (Match-3)

import { GameState } from "shared/types";

/** UI管理クラス（ゲーム状態表示） */
export class UIManager {
	private screenGui: ScreenGui;
	private scoreLabel: TextLabel;
	private movesLabel: TextLabel;
	private matchesLabel: TextLabel;
	private instructionLabel: TextLabel;
	private startButton: TextButton;
	private onStartGameCallback?: () => void;

	constructor(player: Player) {
		// ScreenGuiを作成
		this.screenGui = new Instance("ScreenGui");
		this.screenGui.Name = "RainbowCubeUI";
		this.screenGui.ResetOnSpawn = false;
		this.screenGui.Parent = player.WaitForChild("PlayerGui");

		// 各UIラベルを作成
		this.scoreLabel = this.createGameStateUI();
		this.movesLabel = this.createMovesUI();
		this.matchesLabel = this.createMatchesUI();
		this.instructionLabel = this.createInstructionUI();
		this.startButton = this.createStartButton();
	}

	/** スコア表示UI作成 */
	private createGameStateUI(): TextLabel {
		const label = new Instance("TextLabel");
		label.Name = "ScoreLabel";
		label.Size = new UDim2(0, 200, 0, 50);
		label.Position = new UDim2(0, 20, 0, 20);
		label.BackgroundColor3 = new Color3(0, 0, 0);
		label.BackgroundTransparency = 0.5;
		label.BorderSizePixel = 0;
		label.Text = "Score: 0";
		label.TextColor3 = new Color3(1, 1, 1);
		label.TextSize = 24;
		label.Font = Enum.Font.SourceSansBold;
		label.TextXAlignment = Enum.TextXAlignment.Left;
		label.Parent = this.screenGui;

		return label;
	}

	/** 手数表示UI作成 */
	private createMovesUI(): TextLabel {
		const label = new Instance("TextLabel");
		label.Name = "MovesLabel";
		label.Size = new UDim2(0, 200, 0, 40);
		label.Position = new UDim2(0, 20, 0, 75);
		label.BackgroundColor3 = new Color3(0, 0, 0);
		label.BackgroundTransparency = 0.5;
		label.BorderSizePixel = 0;
		label.Text = "Moves: 0";
		label.TextColor3 = new Color3(1, 1, 1);
		label.TextSize = 20;
		label.Font = Enum.Font.SourceSans;
		label.TextXAlignment = Enum.TextXAlignment.Left;
		label.Parent = this.screenGui;

		return label;
	}

	/** マッチ回数表示UI作成 */
	private createMatchesUI(): TextLabel {
		const label = new Instance("TextLabel");
		label.Name = "MatchesLabel";
		label.Size = new UDim2(0, 200, 0, 40);
		label.Position = new UDim2(0, 20, 0, 120);
		label.BackgroundColor3 = new Color3(0, 0, 0);
		label.BackgroundTransparency = 0.5;
		label.BorderSizePixel = 0;
		label.Text = "Matches: 0";
		label.TextColor3 = new Color3(1, 1, 1);
		label.TextSize = 20;
		label.Font = Enum.Font.SourceSans;
		label.TextXAlignment = Enum.TextXAlignment.Left;
		label.Parent = this.screenGui;

		return label;
	}

	/** 操作説明UI作成 */
	private createInstructionUI(): TextLabel {
		const label = new Instance("TextLabel");
		label.Name = "InstructionLabel";
		label.Size = new UDim2(0, 400, 0, 80);
		label.Position = new UDim2(1, -420, 1, -100);
		label.BackgroundColor3 = new Color3(0, 0, 0);
		label.BackgroundTransparency = 0.5;
		label.BorderSizePixel = 0;
		label.Text = "Left Click: Select blocks to swap\nRight Click: Clear selection";
		label.TextColor3 = new Color3(1, 1, 1);
		label.TextSize = 18;
		label.Font = Enum.Font.SourceSans;
		label.TextXAlignment = Enum.TextXAlignment.Left;
		label.TextYAlignment = Enum.TextYAlignment.Top;
		label.Parent = this.screenGui;

		return label;
	}

	/** ゲーム状態を更新 */
	updateGameState(gameState: GameState): void {
		this.scoreLabel.Text = `Score: ${gameState.score}`;
		this.movesLabel.Text = `Moves: ${gameState.moves}`;
		this.matchesLabel.Text = `Matches: ${gameState.matchCount}`;
	}

	/** 選択状態を更新 */
	updateSelectionInfo(selectedCount: number): void {
		if (selectedCount === 0) {
			this.instructionLabel.Text = "Left Click: Select blocks to swap\nRight Click: Clear selection";
		} else if (selectedCount === 1) {
			this.instructionLabel.Text = "Select second block to swap\nRight Click: Clear selection";
		} else {
			this.instructionLabel.Text = "Swapping blocks...\nRight Click: Clear selection";
		}
	}

	/** スタートボタンUI作成 */
	private createStartButton(): TextButton {
		const button = new Instance("TextButton");
		button.Name = "StartButton";
		button.Size = new UDim2(0, 300, 0, 80);
		button.Position = new UDim2(0.5, -150, 0.5, -40);
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 100);
		button.BorderSizePixel = 0;
		button.Text = "🌈 ゲームスタート 🌈";
		button.TextColor3 = new Color3(1, 1, 1);
		button.TextSize = 32;
		button.Font = Enum.Font.SourceSansBold;
		button.Visible = true;
		button.Parent = this.screenGui;

		// ボタンのホバー効果
		button.MouseEnter.Connect(() => {
			button.BackgroundColor3 = Color3.fromRGB(0, 230, 120);
		});

		button.MouseLeave.Connect(() => {
			button.BackgroundColor3 = Color3.fromRGB(0, 200, 100);
		});

		// クリックイベント
		button.MouseButton1Click.Connect(() => {
			this.onStartGame();
		});

		return button;
	}

	/** スタートボタンクリック時の処理 */
	private onStartGame(): void {
		// ボタンを非表示
		this.startButton.Visible = false;

		// コールバック呼び出し
		this.onStartGameCallback?.();

		print("[UI] Game started!");
	}

	/** ゲーム開始コールバックを設定 */
	setOnStartGameCallback(callback: () => void): void {
		this.onStartGameCallback = callback;
	}

	/** スタートボタンを再表示 */
	showStartButton(): void {
		this.startButton.Visible = true;
	}

	/** スタートボタンを非表示 */
	hideStartButton(): void {
		this.startButton.Visible = false;
	}
}
