# Posterize Shader <!-- omit from toc -->

Mimic some "cel shading" in your GMod scene

## Table of Contents <!-- omit from toc -->

- [Description](#description)
  - [Features](#features)
  - [Rational](#rational)
  - [Remarks](#remarks)
- [Disclaimer](#disclaimer)
- [Pull Requests](#pull-requests)
- [Credits](#credits)

## Description

|![Preview](/media/posterize-preview.png)|
|--|
|A combination of posterize, hatching, and outlines. This scene is lit with lamps. Polarize colors are at zero, which helps achieve the hard edges on the shadows and ultimately adds contrast|

This adds an additive posterize shader. You can find this addon in `Post Process Tab > Shaders > Posterize (vlazed)`

### Features

- **Screenspace posterize effect**
- **Change color of posterizing**: Customize your hatches to fit your scene

> [!NOTE]
> This shader currently fullbright colors to rendertarget `_rt_Color`.

> [!WARNING]
> (Projected texture) flashlights causes bugs with materials with environment maps and causes flickering with map decals.

### Rational

Cel shading in GMod can be achieved through a ramp (or lightwarp) texture, using hard edges instead of a soft gradient. Map lighting and dynamic lights can produce cel shading results; projected textures still produce soft gradients. While one can choose to "harden" the edges of projected textures by increasing their brightness, one also loses texture detail.

This posterize shader helps achieve a cel shading effect that is compatible with projected textures. Furthermore, cel shading can be applied on brushes (as opposed to models).

### Remarks

This shader is adapted from the following tutorial:

- https://martinwiddowson.artstation.com/blog/2Kpy/a-guide-to-screen-space-halftones-cel-shading-and-toon-shading-for-post-processing-in-unreal-engine-4-20-3

It specifically adapts the cel shading node graph, where the frame buffer lighting is added to a generated color buffer (which is just a fullbright scene).

While the website indicates a cel shading effect, the effect in GMod closely resembles GIMP's Posterize effect. Hence, the shader receives it name from that.

## Disclaimer

## Pull Requests

When making a pull request, make sure to confine to the style seen throughout. Try to add types for new functions or data structures. I used the default [StyLua](https://github.com/JohnnyMorganz/StyLua) formatting style.

## Credits

- Martin Widdowson: [Cel shader nodegraph](https://martinwiddowson.artstation.com/blog/2Kpy/a-guide-to-screen-space-halftones-cel-shading-and-toon-shading-for-post-processing-in-unreal-engine-4-20-3)
- Theoroy: [Possible author of the cel shader (website is down for me)](http://blog.theoroy.com/2017/04/27/anime-look-cel-shading-in-ue4/)
