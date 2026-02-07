-- Compiled with roblox-ts v3.0.0
-- Rainbow Tower Builder - Constants
--* グリッドのサイズ (9x9x9) 
local GRID_SIZE = 9
--* 1ブロックのスタッドサイズ 
local STUD_SIZE = 5
--* レインボーカラー定義 (7色) 
local RAINBOW_COLORS = { Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 127, 255), Color3.fromRGB(148, 0, 211), Color3.fromRGB(255, 192, 203) }
--* カラー名（日本語） 
local COLOR_NAMES = { "赤", "オレンジ", "黄", "緑", "青", "紫", "ピンク" }
--* 色の数 
local COLOR_COUNT = 7
--* マッチに必要な最小ブロック数 
local MIN_MATCH_COUNT = 3
--* プレイヤーが届く最大の高さ（Y座標） 
local MAX_REACH_HEIGHT = 4
--* 各層のブロック数 (9x9) 
local BLOCKS_PER_LAYER = GRID_SIZE * GRID_SIZE
--* グリッド中心のワールド座標 
local GRID_CENTER_POSITION = Vector3.new(0, 0, 0)
return {
	GRID_SIZE = GRID_SIZE,
	STUD_SIZE = STUD_SIZE,
	RAINBOW_COLORS = RAINBOW_COLORS,
	COLOR_NAMES = COLOR_NAMES,
	COLOR_COUNT = COLOR_COUNT,
	MIN_MATCH_COUNT = MIN_MATCH_COUNT,
	MAX_REACH_HEIGHT = MAX_REACH_HEIGHT,
	BLOCKS_PER_LAYER = BLOCKS_PER_LAYER,
	GRID_CENTER_POSITION = GRID_CENTER_POSITION,
}
