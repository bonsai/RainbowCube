# 虹のキューブ - マッチ3パズルゲーム実装プラン

## コンテキスト

現在のRainbow Tower Builder（ブロック配置ゲーム）を、9×9×9のマッチ3パズルゲームに変換します。プレイヤーは2つのブロックを選択して入れ替え、3つ以上同じ色が揃うと消えるゲームメカニクスを実装します。

### ユーザー要件
- **グリッドサイズ**: 9×9×9の立方体（729個のブロック）
- **操作**: 2つのブロックを選択して入れ替え
- **消去ルール**: 3つ以上同じ色が縦・横・奥行きに揃ったら消える
- **制約**: プレイヤーの背の届く範囲（下の方）のみ交換可能
- **色数**: 7色のブロック

### 変更の理由
既存のブロック配置ゲームから、より戦略的なマッチ3パズルゲームへの変更により、よりチャレンジングでやりこみ要素のあるゲーム体験を提供します。

---

## 既存アーキテクチャの活用

### 再利用可能な要素
✅ **グリッドシステム**: 9×9×9グリッド、座標変換ロジック
✅ **通信パターン**: RemoteEventベースのクライアント・サーバー通信
✅ **ブロック管理**: `Map<string, BlockData>`による効率的な管理
✅ **型定義**: `GridPosition`, `BlockData`
✅ **定数**: `GRID_SIZE`, `STUD_SIZE`, `RAINBOW_COLORS`

### 大幅変更が必要な要素
❌ **入力処理**: 配置/破壊 → 2ブロック選択・交換
❌ **ゲームロジック**: 配置判定 → マッチ検出・カスケード処理
❌ **UI**: カラーパレット → 選択状態表示・スコア表示
❌ **勝利条件**: 全層完成 → マッチ3ルールベース

---

## 実装計画

### フェーズ1: コアゲームロジック実装

#### 1.1 定数の更新 (`src/shared/constants.ts`)
```typescript
// 7色に変更
export const RAINBOW_COLORS = [
  Color3.fromRGB(255, 0, 0),    // 赤
  Color3.fromRGB(255, 165, 0),  // オレンジ
  Color3.fromRGB(255, 255, 0),  // 黄
  Color3.fromRGB(0, 255, 0),    // 緑
  Color3.fromRGB(0, 0, 255),    // 青
  Color3.fromRGB(128, 0, 128),  // 紫
  Color3.fromRGB(255, 192, 203) // ピンク
];

// 新規追加
export const COLOR_COUNT = 7;
export const MIN_MATCH_COUNT = 3; // 3つ以上で消える
export const MAX_REACH_HEIGHT = 4; // プレイヤーが届く高さ（Y座標）
```

#### 1.2 型定義の更新 (`src/shared/types.ts`)
```typescript
// 既存の型は維持

// 新規追加
export interface SwapBlocksArgs {
  gridPos1: GridPosition;
  gridPos2: GridPosition;
}

export interface MatchGroup {
  positions: GridPosition[];
  colorIndex: number;
}

export interface CascadeResult {
  matchedGroups: MatchGroup[];
  score: number;
  cascadeDepth: number;
}

export interface GameState {
  score: number;
  moves: number;
  matchCount: number;
}
```

#### 1.3 グリッド管理の拡張 (`src/server/grid.ts`)

**既存メソッドを維持:**
- `gridToWorld()`, `worldToGrid()`: 座標変換
- `getAllBlocks()`: ブロック取得

**新規メソッド追加:**
```typescript
// ランダムな色でグリッドを初期化
initializeGrid(): void

// 2つのブロックの色を交換
swapBlocks(pos1: GridPosition, pos2: GridPosition): boolean

// 指定位置のブロックの色を取得
getColorAt(pos: GridPosition): number | undefined

// 指定位置のブロックの色を設定
setColorAt(pos: GridPosition, colorIndex: number): void

// 縦・横・奥行きの3方向でマッチ検出
detectMatches(): MatchGroup[]

// マッチしたブロックを削除
removeBlocks(positions: GridPosition[]): void

// 重力を適用（上のブロックを落とす）
applyGravity(): GridPosition[] // 移動したブロックの位置を返す

// 空いた場所に新しいブロックを生成
fillEmpty(): GridPosition[] // 新規生成されたブロックの位置を返す
```

**マッチ検出ロジック:**
```typescript
// 各軸（X, Y, Z）で連続する同じ色をカウント
// 3つ以上連続していたらMatchGroupに追加
// 重複を除外して返す
```

#### 1.4 マッチ3ゲームマネージャー (`src/server/match3.ts` - 新規作成)
```typescript
import { GridManager } from "./grid";
import { MatchGroup, CascadeResult } from "shared/types";

export class Match3Manager {
  private gridManager: GridManager;
  private score: number = 0;
  private moveCount: number = 0;

  constructor(gridManager: GridManager) {
    this.gridManager = gridManager;
  }

  // ブロック交換を処理（カスケード含む）
  processSwap(pos1: GridPosition, pos2: GridPosition): CascadeResult {
    // 1. 交換
    this.gridManager.swapBlocks(pos1, pos2);

    // 2. マッチ検出 → 削除 → 重力 → 新規生成 → マッチ再検出
    return this.processCascade();
  }

  // カスケード処理（再帰的にマッチを処理）
  private processCascade(depth = 0): CascadeResult {
    const matches = this.gridManager.detectMatches();

    if (matches.length === 0) {
      return { matchedGroups: [], score: 0, cascadeDepth: depth };
    }

    // マッチしたブロックを削除
    const allPositions = matches.flatMap(m => m.positions);
    this.gridManager.removeBlocks(allPositions);

    // スコア計算
    const scoreGain = this.calculateScore(matches, depth);
    this.score += scoreGain;

    // 重力適用 → 新規生成
    this.gridManager.applyGravity();
    this.gridManager.fillEmpty();

    // 再帰的にカスケードをチェック
    const nextCascade = this.processCascade(depth + 1);

    return {
      matchedGroups: [...matches, ...nextCascade.matchedGroups],
      score: scoreGain + nextCascade.score,
      cascadeDepth: Math.max(depth + 1, nextCascade.cascadeDepth)
    };
  }

  private calculateScore(matches: MatchGroup[], cascadeDepth: number): number {
    // 基本スコア = マッチ数 × ブロック数
    // カスケードボーナス = 2^cascadeDepth
    const baseScore = matches.reduce((sum, m) => sum + m.positions.length, 0) * 10;
    const cascadeMultiplier = Math.pow(2, cascadeDepth);
    return baseScore * cascadeMultiplier;
  }

  getScore(): number { return this.score; }
  getMoveCount(): number { return this.moveCount; }
  incrementMoves(): void { this.moveCount++; }
}
```

---

### フェーズ2: サーバー側実装

#### 2.1 サーバーメイン (`src/server/main.server.ts`)

**変更内容:**
```typescript
import { ReplicatedStorage } from "@rbxts/services";
import { GridManager } from "./grid";
import { Match3Manager } from "./match3";
import { SwapBlocksArgs } from "shared/types";

// 初期化
const gridManager = new GridManager();
const match3Manager = new Match3Manager(gridManager);

// グリッドをランダムな色で初期化（マッチなしを保証）
gridManager.initializeGrid();

// RemoteEvent作成
const swapBlocksEvent = new Instance("RemoteEvent");
swapBlocksEvent.Name = "SwapBlocksEvent";
swapBlocksEvent.Parent = ReplicatedStorage;

const gameStateEvent = new Instance("RemoteEvent");
gameStateEvent.Name = "GameStateEvent";
gameStateEvent.Parent = ReplicatedStorage;

// ブロック交換処理
swapBlocksEvent.OnServerEvent.Connect((player, ...args) => {
  const { gridPos1, gridPos2 } = args[0] as SwapBlocksArgs;

  print(`[Server] Swap request: ${gridPos1.x},${gridPos1.y},${gridPos1.z} <-> ${gridPos2.x},${gridPos2.y},${gridPos2.z}`);

  // 高さ制限チェック
  if (gridPos1.y > MAX_REACH_HEIGHT || gridPos2.y > MAX_REACH_HEIGHT) {
    print(`[Server] Out of reach!`);
    return;
  }

  // 隣接チェック（縦横奥行きいずれかで隣接）
  const isAdjacent =
    (Math.abs(gridPos1.x - gridPos2.x) === 1 && gridPos1.y === gridPos2.y && gridPos1.z === gridPos2.z) ||
    (gridPos1.x === gridPos2.x && Math.abs(gridPos1.y - gridPos2.y) === 1 && gridPos1.z === gridPos2.z) ||
    (gridPos1.x === gridPos2.x && gridPos1.y === gridPos2.y && Math.abs(gridPos1.z - gridPos2.z) === 1);

  if (!isAdjacent) {
    print(`[Server] Blocks not adjacent!`);
    return;
  }

  // カスケード処理
  match3Manager.incrementMoves();
  const result = match3Manager.processSwap(gridPos1, gridPos2);

  // 結果を全クライアントに送信
  gameStateEvent.FireAllClients({
    score: match3Manager.getScore(),
    moves: match3Manager.getMoveCount(),
    cascadeResult: result
  });

  print(`[Server] Swap processed! Score: ${match3Manager.getScore()}`);
});

print("🌈 Rainbow Cube Match-3 Server Started!");
```

#### 2.2 VictoryCheckerの削除
`src/server/victory.ts`は不要になるため削除します。勝利条件は後のフェーズで実装します。

---

### フェーズ3: クライアント側実装

#### 3.1 入力処理の変更 (`src/client/input.ts`)

**変更内容:**
```typescript
import { ReplicatedStorage } from "@rbxts/services";
import { GridPosition, SwapBlocksArgs } from "shared/types";
import { MAX_REACH_HEIGHT } from "shared/constants";

export class InputHandler {
  private player: Player;
  private mouse: Mouse;
  private swapBlocksEvent: RemoteEvent;
  private selectedPosition?: GridPosition; // 1つ目の選択
  private worldToGridCallback?: (worldPos: Vector3) => GridPosition | undefined;
  private onSelectionChangeCallback?: (pos1?: GridPosition, pos2?: GridPosition) => void;

  constructor(player: Player) {
    this.player = player;
    this.mouse = player.GetMouse();

    // RemoteEvent取得
    this.swapBlocksEvent = ReplicatedStorage.WaitForChild("SwapBlocksEvent") as RemoteEvent;

    this.setupInputHandlers();
  }

  private setupInputHandlers(): void {
    // 左クリック: ブロック選択・交換
    this.mouse.Button1Down.Connect(() => {
      this.onLeftClick();
    });
  }

  private onLeftClick(): void {
    const hitPosition = this.mouse.Hit.Position;
    const gridPos = this.worldToGridCallback?.(hitPosition);

    if (!gridPos) {
      print(`[Input] Click outside grid`);
      return;
    }

    // 高さ制限チェック
    if (gridPos.y > MAX_REACH_HEIGHT) {
      print(`[Input] Block out of reach! (y=${gridPos.y})`);
      return;
    }

    // 1つ目の選択
    if (!this.selectedPosition) {
      this.selectedPosition = gridPos;
      print(`[Input] Selected first block: (${gridPos.x}, ${gridPos.y}, ${gridPos.z})`);
      this.onSelectionChangeCallback?.(this.selectedPosition, undefined);
      return;
    }

    // 2つ目の選択
    const pos1 = this.selectedPosition;
    const pos2 = gridPos;

    // 同じブロックをクリックした場合は選択解除
    if (pos1.x === pos2.x && pos1.y === pos2.y && pos1.z === pos2.z) {
      print(`[Input] Deselected block`);
      this.selectedPosition = undefined;
      this.onSelectionChangeCallback?.(undefined, undefined);
      return;
    }

    print(`[Input] Swapping blocks: (${pos1.x},${pos1.y},${pos1.z}) <-> (${pos2.x},${pos2.y},${pos2.z})`);

    // サーバーに送信
    const args: SwapBlocksArgs = { gridPos1: pos1, gridPos2: pos2 };
    this.swapBlocksEvent.FireServer(args);

    // 選択をリセット
    this.selectedPosition = undefined;
    this.onSelectionChangeCallback?.(undefined, undefined);
  }

  setWorldToGridCallback(callback: (worldPos: Vector3) => GridPosition | undefined): void {
    this.worldToGridCallback = callback;
  }

  onSelectionChange(callback: (pos1?: GridPosition, pos2?: GridPosition) => void): void {
    this.onSelectionChangeCallback = callback;
  }
}
```

#### 3.2 UI更新 (`src/client/ui.ts`)

**変更内容:**
```typescript
import { Players } from "@rbxts/services";

export class UIManager {
  private player: Player;
  private screenGui: ScreenGui;
  private scoreLabel: TextLabel;
  private movesLabel: TextLabel;
  private selectionIndicator: TextLabel;

  constructor(player: Player) {
    this.player = player;
    this.screenGui = this.createUI();
  }

  private createUI(): ScreenGui {
    const gui = new Instance("ScreenGui");
    gui.Name = "Match3UI";
    gui.Parent = this.player.WaitForChild("PlayerGui");

    // スコア表示
    this.scoreLabel = new Instance("TextLabel");
    this.scoreLabel.Size = new UDim2(0, 200, 0, 50);
    this.scoreLabel.Position = new UDim2(0, 10, 0, 10);
    this.scoreLabel.Text = "スコア: 0";
    this.scoreLabel.TextSize = 24;
    this.scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
    this.scoreLabel.BackgroundTransparency = 0.5;
    this.scoreLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    this.scoreLabel.Parent = gui;

    // 移動数表示
    this.movesLabel = new Instance("TextLabel");
    this.movesLabel.Size = new UDim2(0, 200, 0, 50);
    this.movesLabel.Position = new UDim2(0, 10, 0, 70);
    this.movesLabel.Text = "移動: 0";
    this.movesLabel.TextSize = 24;
    this.movesLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
    this.movesLabel.BackgroundTransparency = 0.5;
    this.movesLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    this.movesLabel.Parent = gui;

    // 選択状態表示
    this.selectionIndicator = new Instance("TextLabel");
    this.selectionIndicator.Size = new UDim2(0, 300, 0, 50);
    this.selectionIndicator.Position = new UDim2(0, 10, 0, 130);
    this.selectionIndicator.Text = "ブロックを選択してください";
    this.selectionIndicator.TextSize = 20;
    this.selectionIndicator.TextColor3 = Color3.fromRGB(255, 255, 255);
    this.selectionIndicator.BackgroundTransparency = 0.5;
    this.selectionIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50);
    this.selectionIndicator.Parent = gui;

    return gui;
  }

  updateScore(score: number): void {
    this.scoreLabel.Text = `スコア: ${score}`;
  }

  updateMoves(moves: number): void {
    this.movesLabel.Text = `移動: ${moves}`;
  }

  updateSelection(pos1?: GridPosition, pos2?: GridPosition): void {
    if (!pos1) {
      this.selectionIndicator.Text = "ブロックを選択してください";
    } else if (!pos2) {
      this.selectionIndicator.Text = `選択中: (${pos1.x}, ${pos1.y}, ${pos1.z})`;
    } else {
      this.selectionIndicator.Text = `交換中...`;
    }
  }

  showMatchFeedback(matchCount: number, score: number): void {
    // マッチ時のフィードバック表示（後で実装）
    print(`[UI] Match! Count: ${matchCount}, Score: +${score}`);
  }
}
```

#### 3.3 クライアントメイン (`src/client/main.client.ts`)

**変更内容:**
```typescript
import { Players, ReplicatedStorage } from "@rbxts/services";
import { UIManager } from "./ui";
import { InputHandler } from "./input";
import { GRID_SIZE, STUD_SIZE, GRID_CENTER_POSITION } from "shared/constants";
import { GridPosition } from "shared/types";

const player = Players.LocalPlayer;
if (!player) error("LocalPlayer not found!");

// UI・入力初期化
const uiManager = new UIManager(player);
const inputHandler = new InputHandler(player);

// ワールド座標→グリッド座標変換
function worldToGrid(worldPos: Vector3): GridPosition | undefined {
  const relative = worldPos.sub(GRID_CENTER_POSITION);

  const x = math.floor(relative.X / STUD_SIZE + (GRID_SIZE - 1) / 2 + 0.5);
  const y = math.floor(relative.Y / STUD_SIZE + 0.5);
  const z = math.floor(relative.Z / STUD_SIZE + (GRID_SIZE - 1) / 2 + 0.5);

  if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE && z >= 0 && z < GRID_SIZE) {
    return { x, y, z };
  }

  return undefined;
}

inputHandler.setWorldToGridCallback(worldToGrid);

// 選択状態の変更をUIに反映
inputHandler.onSelectionChange((pos1, pos2) => {
  uiManager.updateSelection(pos1, pos2);
});

// ゲーム状態の更新を受信
const gameStateEvent = ReplicatedStorage.WaitForChild("GameStateEvent") as RemoteEvent;
gameStateEvent.OnClientEvent.Connect((data: any) => {
  uiManager.updateScore(data.score);
  uiManager.updateMoves(data.moves);

  if (data.cascadeResult && data.cascadeResult.matchedGroups.length > 0) {
    const matchCount = data.cascadeResult.matchedGroups.length;
    uiManager.showMatchFeedback(matchCount, data.cascadeResult.score);
  }
});

print("🌈 Rainbow Cube Match-3 Client Started!");
```

---

## 重要ファイル一覧

### 新規作成
- `src/server/match3.ts` - マッチ3ゲームマネージャー

### 大幅変更
- `src/server/grid.ts` - マッチ検出・カスケード処理追加
- `src/server/main.server.ts` - 交換処理への変更
- `src/client/input.ts` - 2ブロック選択システム
- `src/client/ui.ts` - スコア・選択状態表示
- `src/client/main.client.ts` - 新UIとの連携

### 小規模変更
- `src/shared/constants.ts` - 7色に変更、新定数追加
- `src/shared/types.ts` - 新型定義追加

### 削除
- `src/server/victory.ts` - 不要

---

## 検証方法

### 1. ビルド確認
```powershell
.\dev.ps1
```
- TypeScriptコンパイルが成功
- Rojoビルドが成功
- Studioが開く

### 2. 初期状態確認
Studioでプレイボタンを押して：
- 9×9×9のブロックグリッドが表示される
- ブロックがランダムな7色で初期化されている
- UIに「スコア: 0」「移動: 0」が表示される

### 3. 基本操作確認
- 下層のブロックをクリック → 選択状態になる
- 隣接するブロックをクリック → 色が交換される
- 高い位置のブロック（y > 4）をクリック → "Out of reach"

### 4. マッチ検出確認
- 3つ以上同じ色が揃う → ブロックが消える
- スコアが増加する
- 上のブロックが落ちてくる
- 新しいブロックが上から生成される

### 5. カスケード確認
- 1回の交換で連鎖が発生 → スコアがボーナス込みで増加
- 連鎖数がログに表示される

### 6. エラーケース確認
- 離れたブロックをクリック → "Blocks not adjacent"
- 同じブロックをクリック → 選択解除

---

## 実装の優先順位

### 必須（MVP）
1. ✅ グリッド初期化（ランダム7色）
2. ✅ 2ブロック選択・交換
3. ✅ マッチ検出（3方向）
4. ✅ ブロック削除
5. ✅ 重力適用
6. ✅ 新規ブロック生成
7. ✅ カスケード処理
8. ✅ スコア計算・表示

### 推奨（次フェーズ）
- 選択ハイライト（ビジュアルフィードバック）
- マッチアニメーション
- サウンドエフェクト
- パーティクルエフェクト

### 将来的
- レベルシステム
- 目標スコア・制限時間
- パワーアップ
- マルチプレイヤー対応

---

## リスク・注意点

1. **パフォーマンス**: 729個のPartの管理に注意。必要に応じて最適化。
2. **初期化**: マッチなしでグリッドを生成する必要がある（無限ループ回避）。
3. **カスケード**: 無限ループに陥らないよう再帰深度に制限を設ける。
4. **同期**: サーバーとクライアントのブロック状態を常に同期。
5. **テスト**: エッジケース（角、端）でのマッチ検出をしっかりテスト。

---

## まとめ

既存のグリッドシステムを活用しながら、マッチ3パズルゲームに必要な新しいロジックを追加します。主な変更は入力処理とゲームロジックで、座標システムや通信パターンは再利用できます。段階的に実装することで、各フェーズで動作確認しながら進められます。
