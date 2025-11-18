local mat_posterize = Material("pp/vlazed/posterize")

local pp_posterize = CreateClientConVar("pp_vlazedposterize", "0", true, false, "Enable additive posterize", 0, 1)
local pp_posterize_celcount =
	CreateClientConVar("pp_vlazedposterize_celcount", "20", true, false, "Number of bands in lighting", 0.001)
local pp_posterize_r = CreateClientConVar("pp_vlazedposterize_r", "255", true, false, nil, 0, 255)
local pp_posterize_g = CreateClientConVar("pp_vlazedposterize_g", "255", true, false, nil, 0, 255)
local pp_posterize_b = CreateClientConVar("pp_vlazedposterize_b", "255", true, false, nil, 0, 255)
local pp_posterize_a = CreateClientConVar("pp_vlazedposterize_a", "255", true, false, nil, 0, 255)

local hookName = "vlazed_posterize_hook"
local width, height = ScrW(), ScrH()

function render.DrawVlazedPosterize()
	-- TODO: Use local variables

	render.UpdateScreenEffectTexture()

	mat_posterize:SetFloat("$c0_x", pp_posterize_celcount:GetFloat())
	mat_posterize:SetFloat("$c0_y", pp_posterize_r:GetFloat() / 255)
	mat_posterize:SetFloat("$c0_z", pp_posterize_g:GetFloat() / 255)
	mat_posterize:SetFloat("$c0_w", pp_posterize_b:GetFloat() / 255)
	render.SetMaterial(mat_posterize)
	render.DrawScreenQuad()
end

local function enablePosterize()
	if pp_posterize:GetBool() then
		hook.Add("RenderScreenspaceEffects", hookName, function()
			render.DrawVlazedPosterize()
		end)
	else
		hook.Remove("RenderScreenspaceEffects", hookName)
	end
end

cvars.AddChangeCallback("pp_vlazedposterize", function(cvar, old, new)
	enablePosterize()
end, "vlazed_posterize_callback")
enablePosterize()

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
			pp_vlazedposterize_celcount = 8.00,
		}
		CPanel:ToolPresets("vlazedposterize", options)

		CPanel:CheckBox("Enable", "pp_vlazedposterize")

		CPanel:ColorPicker(
			"Color",
			"pp_vlazedposterize_r",
			"pp_vlazedposterize_g",
			"pp_vlazedposterize_b",
			"pp_vlazedposterize_a"
		)
		CPanel:NumSlider("Cel count", "pp_vlazedposterize_celcount", 1, 20, 0)
	end,
})
