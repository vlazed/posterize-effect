// Defines cEyePos
#include "common_ps_fxc.h"

sampler BASETEXTURE : register(s0);
sampler COLORTEXTURE : register(s1);

float4 CELS   : register(c0);

struct PS_INPUT
{
    float2 uv : TEXCOORD0;             // Position on triangle
    float2 pPos: VPOS;
    float3 view_space_dir : TEXCOORD1; // Projection matrix (used for calculating depth)
};

float4 main(PS_INPUT frag) : COLOR
{
    float4 diffuse = tex2D(BASETEXTURE, frag.uv);
    float4 color = tex2D(COLORTEXTURE, frag.uv);

    // Cel shading (really just a glorified, additive posterize effect for source) from 
    // https://martinwiddowson.artstation.com/blog/2Kpy/a-guide-to-screen-space-halftones-cel-shading-and-toon-shading-for-post-processing-in-unreal-engine-4-20-3
    float intensity = dot(diffuse.rgb, float3(0.2126, 0.7152, 0.0722));
    float cel = floor(CELS.x * intensity) / CELS.x;
    float3 colorMult = CELS.yzw;
    color.rgb *= colorMult;

    float4 result = color + cel;

    return result;
}