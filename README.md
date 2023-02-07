# *MSDF text rendering* - showcase

> ⚠️ This showcase is still being developed, so you may not find some of the listed *features*. ⚠️

***MSDF-showcase*** is a showcase of *glsl shaders* utilizing **MSDF (multi-channel signed distance fields)** to render text in high quality while being *magnified*, *minified* or *rotated* in 3D space. It shows the basic usage of MSDF in text rendering with some additional, more advanced text modifiers.

All assets and characters were generated by the [msdfgen](https://github.com/Chlumsky/msdfgen) utility. Options to create the character assets were MTSDF (multi-channel *true* signed distance field) type with distance field pixel range of 6.

For *2D rendering*, you are better off using a rasterizer since there are no constant text size or rotation modifications, unlike in 3D rendering.

**Remember to** generate a texture atlas with [msdf-atlas-gen](https://github.com/Chlumsky/msdf-atlas-gen) utility and **not to** generate every character texture separately, as shown in this showcase. The utility can also output an *arfont* file containing all character atlas positions, kerning info, spaces between characters and more.

## Shaders and the output in *real-time*

> Read through the README in the [shaders](./shaders) folder for more detailed shader explanations.

To see how the shaders work in real-time, you can download the [**SHADERed**](https://github.com/dfranx/SHADERed/releases) desktop application, open the ***'.sprj'*** file from the repo with the *SHADERed app* and see the output on the canvas. Learn more about *SHADERed* on their official [Tutorial website](https://shadered.org/docs/tutorials.html) or by watching [Youtube tutorials](https://www.youtube.com/playlist?list=PLK0EO-cKorzRAEfwHoJFiIldiyiyDR3-2).

## Content

In the shaders, you can find examples of:

- basic text rendering in 3D space with quality preservation while being *magnified*, *minified* or *rotated*,
- modifying text thickness,
- adding a colored outline with custom thickness to the text,
- applying softness to the body or the text outline,
- custom colored text drop shadow,
- gamma correction

## Basic MSDF usage

The following snippet shows the basic usage of an MSDF texture (*distance field pixel range 4*) to render text while preserving the highest quality. For more info, check out this [explanation](https://github.com/Chlumsky/msdfgen#using-a-multi-channel-distance-field) from the msdfgen creator.

```glsl
uniform sampler2D tex;

in vec2 uvCoord;
out vec4 outColor;

float median(float r, float g, float b) {
    return max(min(r, g), min(max(r, g), b));
}

float screenPxRange() {
    vec2 unitRange = vec2(6.0)/vec2(textureSize(tex, 0));
    vec2 screenTexSize = vec2(1.0)/fwidth(uvCoord);
    return max(0.5*dot(unitRange, screenTexSize), 1.0);
}

void main() {
    vec4 texel = texture(tex, uvCoord);
    float dist = median(texel.r, texel.g, texel.b);

    float pxDist = screenPxRange() * (dist - 0.5);
    float opacity = clamp(pxDist + 0.5, 0.0, 1.0);

    outColor = vec4(0.5, 0.5, 0.5, opacity);
}
```

## MSDF tips

Here are a few valuable tips regarding MSDFs:

- **IMPORTANT:** The result of `screenPxRange()` function in *fragment* shaders must never be lower than 1. If it is lower than 2, there is a high probability that the anti-aliasing will fail. Also, if it is lower than 2, color can start spreading over the whole character quad, and to fix it, add a condition where the shader gets **discarded** if the known *distance* is 0.

- Do **not** use mipmaps. When text is minified, mipmaps will break anti-aliasing.

- **Supersampling** helps with anit-aliasing but reduces performance and FPS.

- **Thicker fonts** can help with quality preservation when the text is downscaled.

- **Gamma correction** also helps with quality preservation when the text is downscaled. 

- **Higher dimensions** per character (32x32 or more) are desirable when generating the MSDF texture. This helps reduce the artefacts created while rendering *more complex and thinner fonts*. These artefacts are caused by the lack of detail on MSDF textures.

- My preference when generating MSDF textures regarding the **distance field pixel range** is **setting it to 6**. However, putting it higher will make no difference and setting it too high will create strange artefacts when rendering.

- MSDF texture **magnify filter** (MagFilter) should be **set to linear** and not nearest, where distance fields won't work in that case.

## Sources, links, articles, discussions, more info

Below, you you can find links to all the sources that helped me learn about MSDF and create the showcase.

> ⚠️ Constantly adding more! ⚠️

#### Intro

- [What is state-of-the-art for text rendering in OpenGL as of version 4.1? - Stack Overflow](https://stackoverflow.com/questions/5262951/what-is-state-of-the-art-for-text-rendering-in-opengl-as-of-version-4-1) - A discussion about today's popular text rendering methods, including SDFs.
- [Text Rendering For Games](https://docs.google.com/presentation/d/1NCYNyR726F6j7vxwxFw0w0t8c6DUbiEMaxwMBbdP__0/edit#slide=id.g43674374e_046) - The presentation covers three different ways to render text for games (one being SDFs).
- [The Valve paper](https://steamcdn-a.akamaihd.net/apps/valve/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf) - This short *pdf*  by *Valve* originally proposed using distance fields to render text.

#### SDFs (Signed distance field)

- [Glyphs, shapes, fonts, signed distance fields - YouTube](https://www.youtube.com/watch?v=1b5hIMqz_wM) - Short video explaining how to generate and use SDFs to render text or other 2D shapes.
- [Drawing Text with Signed Distance Fields in Mapbox GL](https://blog.mapbox.com/drawing-text-with-signed-distance-fields-in-mapbox-gl-b0933af6f817) - This short article covers how SDFs work and the basic usage of SDFs for text rendering.

#### Anti-aliasing SDF text

- [Cinder-SdfText: Initial Release (WIP) - Cinder](https://discourse.libcinder.org/t/cinder-sdftext-initial-release-wip) - Interesting discussion about an SDF text renderer and improving the shader code to preserve the quality of minified SDF texts.
- [Signed-distance-field fonts look crappy at small pt sizes - JVM Gaming](https://jvm-gaming.org/t/solved-signed-distance-field-fonts-look-crappy-at-small-pt-sizes/49617) - Another interesting discussion where preserving the quality of scaled SDF texts is the main topic.
- [Antialiasing with a signed distance field - Musing Mortoray](https://mortoray.com/antialiasing-with-a-signed-distance-field/) - This article explains how to set up the shader code for true anti-aliasing correctly.
- [Antialiasing For SDF Textures](https://drewcassidy.me/2020/06/26/sdf-antialiasing/) - An article which shows different ways of setting up the shader code for better anti-aliasing. Some parts are based on the explanations of the article above.
- [Rendering Signed Distance Fields, Part 1 « Essential Math Weblog](http://www.essentialmath.com/blog/?p=111) - Part 1 of the blog explains the math behind the anti-aliasing of SDF text.
- [Rendering Signed Distance Fields, Part 2 « Essential Math Weblog](http://www.essentialmath.com/blog/?p=128) - Part 2 of the blog goes more in in-depth.
- [Rendering Signed Distance Fields, Part 3 « Essential Math Weblog](https://www.essentialmath.com/blog/?p=151) - Part 3 of the blog presents the final shader product for anti-aliasing.
- [Partial Derivatives (fwidth) | Ronja's tutorials](https://www.ronja-tutorials.com/post/046-fwidth/) - Explains what and how the partial derivate functions fwidth(), ddx() and ddy() work *(dFdx() and dFdy() in glsl)*.

#### MSDFs (Multi-channel signed distance field)

- [Chlumsky/msdfgen: Multi-channel signed distance field generator](https://github.com/Chlumsky/msdfgen) - Utility for generating SDF and M(T)SDF from vector shapes and fonts. Use [msdf-atlas-gen](https://github.com/Chlumsky/msdf-atlas-gen) to generate font atlases for rendering. If this project didn't exist, this repo wouldn't exist either.
- [Implementing SDF/MSDF Font In OpenGL](https://medium.com/@calebfaith/implementing-msdf-font-in-opengl-ea09a9ab7e00) - An article covering how MSDFs are generated, how they work and the basic usage of MSDFs for text rendering.
- [MSDF text rendering performance demonstration - YouTube](https://www.youtube.com/watch?v=r-2z-ccuZKE) - Short video presenting the performance of using MSDFs when rendering a lot of text. Note that minified text looks much worse than the rest, but I am convinced that methods used in this showcase avoid that efficiently.

#### Helpful code snippets

- [leochocolat/three-msdf-text-utils](https://github.com/leochocolat/three-msdf-text-utils/tree/main/src/MSDFTextMaterial/shaders),
- [suikki/sdf_text_sample](https://github.com/suikki/sdf_text_sample/tree/master/assets/shaders),
- [Evolut-Group-Pty-Ltd/Lavo-2.0](https://github.com/Evolut-Group-Pty-Ltd/Lavo-2.0/blob/main/src/scene/components/Text/frag.glsl),
- [wassy310/MJ_Simulator](https://github.com/wassy310/MJ_Simulator/blob/master/MJ_simulator/App/engine/shader/glsl/msdffont_outlineshadow.frag),
- [maltaisn/msdf-gdx](https://github.com/maltaisn/msdf-gdx/blob/master/lib/src/main/resources/font.frag),
- [MSDF Preview](https://gist.github.com/Chlumsky/263c960ae0a7df59afc2da4051eb0553),
- [Cierpliwy/sdf-test](https://github.com/Cierpliwy/sdf-test),
- [jinleili/sdf-text-view](https://github.com/jinleili/sdf-text-view/tree/master/shader-wgsl) - *wgsl* shaders,
- [TinySDF demo](https://mapbox.github.io/tiny-sdf/),

### The repo motive

There are two reasons why I wanted to make this repo. The first reason is that I am very interested in distance fields and their usage in rendering. Therefore, this repo helps me to understand and learn more. The second reason is the rare findings on this topic over the internet. While searching for code examples and usage information regarding the subject, I could only find a few articles. Also, searching on GitHub, I often found the same basic *code snippet* repeating itself in almost every repo. I want to fill this repo with as much information and code examples (basic to advanced) as possible, so other people don't have to search aimlessly.

### Contributing and questions

All contributions, such as fixing grammar, adding new sources and improving shader code, are welcome.

If you have questions about the topic feel free to post them in the [discussions section](https://github.com/Blatko1/MSDF-showcase/discussions).
