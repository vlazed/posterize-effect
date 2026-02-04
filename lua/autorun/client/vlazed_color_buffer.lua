local enableBuffer = CreateClientConVar("color_buffer_enable", "1", true, false, nil, 0, 1)

local shaderName = "vlazed_color_buffer"

local rt_Color = GetRenderTargetEx(
	"_rt_Color",
	ScrW(),
	ScrH(),
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_SHARED,
	bit.bor(4, 8, 16, 256, 512, 32768, 8388608),
	0,
	IMAGE_FORMAT_RGB888
)

local scrFxTexture = render.GetScreenEffectTexture()

local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local render_UpdateRefractTexture = render.UpdateRefractTexture
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local render_SetLightingMode = render.SetLightingMode
local render_SuppressEngineLighting = render.SuppressEngineLighting
local render_PushRenderTarget = render.PushRenderTarget
local render_RenderView = render.RenderView
local render_PopRenderTarget = render.PopRenderTarget

function render.DrawColorBuffer()
	render_UpdateScreenEffectTexture()
	render_UpdateRefractTexture()
	render_CopyRenderTargetToTexture(scrFxTexture)

	-- SetLightingMode does not affect materials with $bumpmap or $lightwarp
	-- So SuppressEngineLighting is required. However, there are some lighting
	-- artifacts from this
	-- TODO: Monitor for changes to lightingmode behavior
	render_SetLightingMode(1)
	render_SuppressEngineLighting(true)
	render_PushRenderTarget(rt_Color)
	-- render_PushRenderTarget() -- Debug mode

	render_RenderView()

	render_PopRenderTarget()
	render_SetLightingMode(0)
	render_SuppressEngineLighting(false)
end

local colorBuffer = render.DrawColorBuffer

local function enableColorBuffer(enabled)
	hook.Remove("RenderScreenspaceEffects", shaderName)
	hook.Remove("PreRender", shaderName)
	if enabled then
		hook.Add("RenderScreenspaceEffects", shaderName, function()
			colorBuffer()
		end)
	end
end

enableColorBuffer(enableBuffer:GetBool())

cvars.AddChangeCallback("color_buffer_enable", function(convar, oldValue, newValue)
	enableColorBuffer(tobool(newValue))
end)
