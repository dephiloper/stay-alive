extends TextureProgress

const STEP_SIZE: int = 33

func update_value(val: float):
	value = val * STEP_SIZE
