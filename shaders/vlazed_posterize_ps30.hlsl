// Defines cEyePos
#include "common_ps_fxc.h"

sampler BASETEXTURE : register(s0);
sampler COLORTEXTURE : register(s1);

float4 CELS   : register(c0);

float4 LIFT   : register(c1);
float4 GAMMA   : register(c2);
float4 GAIN   : register(c3);

struct PS_INPUT
{
    float2 uv : TEXCOORD0;             // Position on triangle
    float2 pPos: VPOS;
    float3 view_space_dir : TEXCOORD1; // Projection matrix (used for calculating depth)
};

// LiftGammaGain by 3an and CeeJay.dk
// https://github.com/CeeJayDK/SweetFX/blob/16d1a42247cb5baaf660120ee35c9a33bb94649c/Shaders/SweetFX/LiftGammaGain.fx#L27
float3 LiftGammaGainPass(float3 color)
{
    float3 RGB_Lift = LIFT.rgb;
    float3 RGB_Gamma = GAMMA.rgb;
    float3 RGB_Gain = GAIN.rgb;

	// -- Lift --
	color = color * (1.5 - 0.5 * RGB_Lift) + 0.5 * RGB_Lift - 0.5;
	color = saturate(color); // Is not strictly necessary, but does not cost performance
	
	// -- Gain --
	color *= RGB_Gain; 
	
	// -- Gamma --
	color = pow(abs(color), 1.0 / RGB_Gamma);
	
	return saturate(color);
}

float4 main(PS_INPUT frag) : COLOR
{
    float4 diffuse = tex2D(BASETEXTURE, frag.uv);
    float4 color = tex2D(COLORTEXTURE, frag.uv);

    // Cel shading (really just a glorified, additive posterize effect for source) from 
    // https://martinwiddowson.artstation.com/blog/2Kpy/a-guide-to-screen-space-halftones-cel-shading-and-toon-shading-for-post-processing-in-unreal-engine-4-20-3
    float intensity = dot(diffuse.rgb, float3(0.2126, 0.7152, 0.0722));
    float3 intensity3 = LiftGammaGainPass(intensity);

    float3 cel = floor(CELS.x * intensity3) / CELS.x;
    float3 colorMult = CELS.yzw;
    color.rgb *= colorMult;

    float4 result = float4(color + cel, 1);

    return result;
}