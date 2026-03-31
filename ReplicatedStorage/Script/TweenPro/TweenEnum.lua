local TweenEnum = {}

TweenEnum.PlayState = {
	Playing = 1,
	Pasue = 2,
	Stop = 3,
	Complete = 4
}

TweenEnum.LoopType = {
	Once = 1,
	PingPong = 2,
	Loop = 3,
}

TweenEnum.ForwardType = {
	Forward = 1,
	Backward = 2,
}

TweenEnum.TweenType = {
	-- Value
	Value = "Value",
	-- Part
	PartPosition = "PartPosition",
	PartRotation = "PartRotation",
	PartScale = "PartScale",
	PartColor = "PartColor",
	-- Model
	ModelPosition = "ModelPosition",
	ModelRotation = "ModelRotation",
	ModelScale = "ModelScale",
	-- Gui
	GuiRotation = "GuiRotation",
	GuiTransparency = "GuiTransparency",
	GuiColor = "GuiColor",
	GuiAnchor = "GuiAnchor",
	GuiPosition = "GuiPosition",
	GuiPositionOffset = "GuiPositionOffset",
	GuiPositionValue = "GuiPositionValue",
	GuiScale = "GuiScale",
	GuiScaleValue = "GuiScaleValue",
	GuiScaleOffset = "GuiScaleOffset",
	GuiGroupTransparency = "GuiGroupTransparency",
	-- Player
	PlayerPosition = "PlayerPosition",
	PlayerRotation = "PlayerRotation",
	-- Camera
	CameraFOV = "CameraFOV",
}

TweenEnum.EaseType = {
	Linear = "Linear",
	Circular = "Circular",
	InQuad = "InQuad",
	OutQuad = "OutQuad",
	InOutQuad = "InOutQuad",
	InCubic = "InCubic",
	OutCubic = "OutCubic",
	InOutCubic = "InOutCubic",
	InQuart = "InQuart",
	OutQuart = "OutQuart",
	InOutQuart = "InOutQuart",
	InQuint = "InQuint",
	OutQuint = "OutQuint",
	InOutQuint = "InOutQuint",
	InSine = "InSine",
	OutSine = "OutSine",
	InOutSine = "InOutSine",
	InExpo = "InExpo",
	OutExpo = "OutExpo",
	InOutExpo = "InOutExpo",
	InCirc = "InCirc",
	OutCirc = "OutCirc",
	InOutCirc = "InOutCirc",
	Spring = "Spring",
	InBack = "InBack",
	OutBack = "OutBack",
	InOutBack = "InOutBack",
	Punch = "Punch",
	InBounce = "InBounce",
	OutBounce = "OutBounce",
	InOutBounce = "InOutBounce",
	InElastic = "InElastic",
	OutElastic = "OutElastic",
	InOutElastic = "InOutElastic",
	Sin = "Sin",
	Cos = "Cos",
	Flash = "Flash",
	Step = "Step",
	Parabola = "Parabola",
	Shake = "Shake",
	Dash = "Dash",
}

return TweenEnum
