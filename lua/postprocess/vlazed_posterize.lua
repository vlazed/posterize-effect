local mat_posterize = Material("pp/vlazed/posterize")
local mat_posterize_cel = Material("pp/vlazed/posterize_cel")
local mat_posterize_light = Material("pp/vlazed/posterize_light")
local mat_posterize_color = Material("pp/vlazed/posterize_color")

local pp_posterize = CreateClientConVar("pp_vlazedposterize", "0", true, false, "Enable additive posterize", 0, 1)

local pp_posterize_debug_color =
	CreateClientConVar("pp_vlazedposterize_debug_color", "0", true, false, "Show color stage of posterize shader", 0, 1)
local pp_posterize_debug_light = CreateClientConVar(
	"pp_vlazedposterize_debug_light",
	"0",
	true,
	false,
	"Show lighting stage of posterize shader",
	0,
	1
)
local pp_posterize_debug_cel =
	CreateClientConVar("pp_vlazedposterize_debug_cel", "0", true, false, "Show cel stage of posterize shader", 0, 1)

local pp_posterize_celcount =
	CreateClientConVar("pp_vlazedposterize_celcount", "20", true, false, "Number of bands in lighting", 0.001)
local pp_posterize_r = CreateClientConVar("pp_vlazedposterize_r", "255", true, false, nil, 0, 255)
local pp_posterize_g = CreateClientConVar("pp_vlazedposterize_g", "255", true, false, nil, 0, 255)
local pp_posterize_b = CreateClientConVar("pp_vlazedposterize_b", "255", true, false, nil, 0, 255)
local pp_posterize_a = CreateClientConVar("pp_vlazedposterize_a", "255", true, false, nil, 0, 255)

local pp_posterize_lift_r = CreateClientConVar("pp_vlazedposterize_lift_r", "255", true, false, nil, 0, 255)
local pp_posterize_lift_g = CreateClientConVar("pp_vlazedposterize_lift_g", "255", true, false, nil, 0, 255)
local pp_posterize_lift_b = CreateClientConVar("pp_vlazedposterize_lift_b", "255", true, false, nil, 0, 255)
local pp_posterize_lift_a = CreateClientConVar("pp_vlazedposterize_lift_a", "255", true, false, nil, 0, 255)
local pp_posterize_lift_scale = CreateClientConVar("pp_vlazedposterize_lift", "1", true, false, nil, 0, 255)

local pp_posterize_gamma_r = CreateClientConVar("pp_vlazedposterize_gamma_r", "255", true, false, nil, 0, 255)
local pp_posterize_gamma_g = CreateClientConVar("pp_vlazedposterize_gamma_g", "255", true, false, nil, 0, 255)
local pp_posterize_gamma_b = CreateClientConVar("pp_vlazedposterize_gamma_b", "255", true, false, nil, 0, 255)
local pp_posterize_gamma_a = CreateClientConVar("pp_vlazedposterize_gamma_a", "255", true, false, nil, 0, 255)
local pp_posterize_gamma_scale = CreateClientConVar("pp_vlazedposterize_gamma", "1", true, false, nil, 0, 255)

local pp_posterize_gain_r = CreateClientConVar("pp_vlazedposterize_gain_r", "255", true, false, nil, 0, 255)
local pp_posterize_gain_g = CreateClientConVar("pp_vlazedposterize_gain_g", "255", true, false, nil, 0, 255)
local pp_posterize_gain_b = CreateClientConVar("pp_vlazedposterize_gain_b", "255", true, false, nil, 0, 255)
local pp_posterize_gain_a = CreateClientConVar("pp_vlazedposterize_gain_a", "255", true, false, nil, 0, 255)
local pp_posterize_gain_scale = CreateClientConVar("pp_vlazedposterize_gain", "1", true, false, nil, 0, 255)

local posterizeHook = "vlazed_posterize_hook"

---@type IMaterial
local IMAT = FindMetaTable("IMaterial")
local SetFloat = IMAT.SetFloat

local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local render_SetMaterial = render.SetMaterial
local render_DrawScreenQuad = render.DrawScreenQuad

function render.DrawVlazedPosterize()
	render_UpdateScreenEffectTexture()

	local mat = mat_posterize

	-- TODO: Investigate why SetString on pixshader doesn't affect the shader
	if pp_posterize_debug_cel:GetBool() then
		mat = mat_posterize_cel
	elseif pp_posterize_debug_light:GetBool() then
		mat = mat_posterize_light
	elseif pp_posterize_debug_color:GetBool() then
		mat = mat_posterize_color
	end

	SetFloat(mat, "$c0_x", pp_posterize_celcount:GetFloat())
	SetFloat(mat, "$c0_y", pp_posterize_r:GetFloat() / 255)
	SetFloat(mat, "$c0_z", pp_posterize_g:GetFloat() / 255)
	SetFloat(mat, "$c0_w", pp_posterize_b:GetFloat() / 255)

	local liftScale = pp_posterize_lift_scale:GetFloat()
	SetFloat(mat, "$c1_x", pp_posterize_lift_r:GetFloat() / 255 * liftScale)
	SetFloat(mat, "$c1_y", pp_posterize_lift_g:GetFloat() / 255 * liftScale)
	SetFloat(mat, "$c1_z", pp_posterize_lift_b:GetFloat() / 255 * liftScale)
	local gammaScale = pp_posterize_gamma_scale:GetFloat()
	SetFloat(mat, "$c2_x", pp_posterize_gamma_r:GetFloat() / 255 * gammaScale)
	SetFloat(mat, "$c2_y", pp_posterize_gamma_g:GetFloat() / 255 * gammaScale)
	SetFloat(mat, "$c2_z", pp_posterize_gamma_b:GetFloat() / 255 * gammaScale)
	local gainScale = pp_posterize_gain_scale:GetFloat()
	SetFloat(mat, "$c3_x", pp_posterize_gain_r:GetFloat() / 255 * gainScale)
	SetFloat(mat, "$c3_y", pp_posterize_gain_g:GetFloat() / 255 * gainScale)
	SetFloat(mat, "$c3_z", pp_posterize_gain_b:GetFloat() / 255 * gainScale)

	render_SetMaterial(mat)
	render_DrawScreenQuad()
end

local posterize = render.DrawVlazedPosterize

local function enablePosterize(enabled)
	hook.Remove("RenderScreenspaceEffects", posterizeHook)
	if enabled then
		hook.Add("RenderScreenspaceEffects", posterizeHook, function()
			posterize()
		end)
	end
end

cvars.AddChangeCallback("pp_vlazedposterize", function(cvar, old, new)
	enablePosterize(tobool(new))
end, "vlazed_posterize_callback")
enablePosterize(pp_posterize:GetBool())

---Helper for DForm
---@param cPanel ControlPanel|DForm
---@param name string
---@param type "ControlPanel"|"DForm"
---@return ControlPanel|DForm
local function makeCategory(cPanel, name, type)
	---@type DForm|ControlPanel
	local category = vgui.Create(type, cPanel)

	category:SetLabel(name)
	cPanel:AddItem(category)
	return category
end

list.Set("PostProcess", "Posterize (vlazed)", {

	icon = "gui/postprocess/vlazedposterize.png",
	convar = "pp_vlazedposterize",
	category = "#shaders_pp",

	cpanel = function(CPanel)
		---@cast CPanel ControlPanel

		CPanel:Help("Apply an additive posterize (or screenspace cel shader) over the scene.")

		local options = {
			pp_vlazedposterize_r = 255,
			pp_vlazedposterize_g = 255,
			pp_vlazedposterize_b = 255,
			pp_vlazedposterize_a = 255,

			pp_vlazedposterize_lift = 1,
			pp_vlazedposterize_lift_r = 255,
			pp_vlazedposterize_lift_g = 255,
			pp_vlazedposterize_lift_b = 255,
			pp_vlazedposterize_lift_a = 255,

			pp_vlazedposterize_gamma = 1,
			pp_vlazedposterize_gamma_r = 255,
			pp_vlazedposterize_gamma_g = 255,
			pp_vlazedposterize_gamma_b = 255,
			pp_vlazedposterize_gamma_a = 255,

			pp_vlazedposterize_gain = 1,
			pp_vlazedposterize_gain_r = 255,
			pp_vlazedposterize_gain_g = 255,
			pp_vlazedposterize_gain_b = 255,
			pp_vlazedposterize_gain_a = 255,
			pp_vlazedposterize_celcount = 8.00,
		}
		CPanel:ToolPresets("vlazedposterize", options)

		CPanel:CheckBox("Enable", "pp_vlazedposterize")
		CPanel:CheckBox("Enable color buffer", "color_buffer_enable")

		CPanel:ColorPicker(
			"Color",
			"pp_vlazedposterize_r",
			"pp_vlazedposterize_g",
			"pp_vlazedposterize_b",
			"pp_vlazedposterize_a"
		)
		CPanel:NumSlider("Cel count", "pp_vlazedposterize_celcount", 1, 20, 0)

		local lightSettings = makeCategory(CPanel, "Light Settings", "ControlPanel")
		lightSettings:ColorPicker(
			"Lift",
			"pp_vlazedposterize_lift_r",
			"pp_vlazedposterize_lift_g",
			"pp_vlazedposterize_lift_b",
			"pp_vlazedposterize_lift_a"
		)
		lightSettings:NumSlider("Lift Multiplier", "pp_vlazedposterize_lift", 0, 100, 5)

		lightSettings:ColorPicker(
			"Gamma",
			"pp_vlazedposterize_gamma_r",
			"pp_vlazedposterize_gamma_g",
			"pp_vlazedposterize_gamma_b",
			"pp_vlazedposterize_gamma_a"
		)
		lightSettings:NumSlider("Gamma Multiplier", "pp_vlazedposterize_gamma", 0, 100, 5)

		lightSettings:ColorPicker(
			"Gain",
			"pp_vlazedposterize_gain_r",
			"pp_vlazedposterize_gain_g",
			"pp_vlazedposterize_gain_b",
			"pp_vlazedposterize_gain_a"
		)
		lightSettings:NumSlider("Gain Multiplier", "pp_vlazedposterize_gain", 0, 100, 5)

		local debugSettings = makeCategory(CPanel, "Debug", "ControlPanel")
		debugSettings:CheckBox("Color", "pp_vlazedposterize_debug_color")
		debugSettings:CheckBox("Lighting", "pp_vlazedposterize_debug_light")
		debugSettings:CheckBox("Cel", "pp_vlazedposterize_debug_cel")
	end,
})
