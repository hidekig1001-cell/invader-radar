# 規則の層（SPEC.md 2 節）: ゲームの決まりの入口。
# 土台の版: 駒が level.target 個あれば解けた、だけ。
# ゲームの決まり（区域・行・列に 1 つずつ、隣り合わない、など）は、ここを CR で置き換えて足す。
extends RefCounted


static func is_solved(board_state, level) -> bool:
	if board_state == null or level == null:
		return false
	return board_state.pieces().size() == level.target
