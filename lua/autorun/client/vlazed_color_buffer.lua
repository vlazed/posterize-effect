local enableBuffer = CreateClientConVar("color_buffer_enable", "1", true, false, nil, 0, 1)

local shaderName = "vlazed_color_buffer"

local rt_Color = GetRenderTargetEx(
	"_rt_Color",
	ScrW(),
	ScrH(),
	RT_SIZE_FULL_FRAME_BUFFER,
	MATERIAL_RT_DEPTH_SHARED,
	bit.bor(4, 8, 16, 256, 512),
	0,
	IMAGE_FORMAT_RGB888
)

local scrFxTexture = render.GetScreenEffectTexture()

-- FIXME: materials with a envmap flash to white when shining a flashlight at it
-- also makes decals on brushes flicker
function render.DrawColorBuffer()
	render.UpdateScreenEffectTexture()
	render.UpdateRefractTexture()
	render.CopyRenderTargetToTexture(scrFxTexture)

	render.SetLightingMode(1)
	render.PushRenderTarget(rt_Color)
	-- render.PushRenderTarget() -- Debug mode

	-- render.ClearDepth()
	render.RenderView()
	-- render.DrawScreenQuad()

	render.PopRenderTarget()

	render.SetLightingMode(0)
end

hook.Remove("RenderScreenspaceEffects", shaderName)
hook.Remove("PreRender", shaderName)
if enableBuffer:GetBool() then
	hook.Add("RenderScreenspaceEffects", shaderName, function()
		render.DrawColorBuffer()
	end)
end

cvars.AddChangeCallback("color_buffer_enable", function(convar, oldValue, newValue)
	hook.Remove("RenderScreenspaceEffects", shaderName)
	hook.Remove("PreRender", shaderName)
	if tobool(newValue) then
		hook.Add("RenderScreenspaceEffects", shaderName, function()
			render.DrawColorBuffer()
		end)
	end
end)
