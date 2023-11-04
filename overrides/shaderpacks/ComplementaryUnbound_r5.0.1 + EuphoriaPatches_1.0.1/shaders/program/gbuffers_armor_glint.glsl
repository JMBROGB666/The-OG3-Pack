//////////////////////////////////
// Complementary Base by EminGT //
//////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

in vec2 texCoord;

flat in vec4 glColor;

//Uniforms//
uniform sampler2D tex;

//Pipeline Constants//

//Common Variables//

//Common Functions//

//Includes//
#ifdef COLOR_CODED_PROGRAMS
	#include "/lib/misc/colorCodedPrograms.glsl"
#endif

//Program//
void main() {
	vec4 color = texture2D(tex, texCoord);
	color *= glColor;

	#ifdef COLOR_CODED_PROGRAMS
		ColorCodeProgram(color);
	#endif

	/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

out vec2 texCoord;

flat out vec4 glColor;

//Uniforms//

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE || defined WAVE_EVERYTHING
	uniform sampler2D noisetex;
	uniform mat4 gbufferModelViewInverse;
#endif

#if defined ATLAS_ROTATION || defined WAVE_EVERYTHING
	uniform vec3 cameraPosition;
	attribute vec4 mc_midTexCoord;
	vec2 lmCoord = GetLightMapCoordinates();
#endif

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE
	#include "/lib/misc/distortWorld.glsl"
#endif

#ifdef WAVE_EVERYTHING
	#include "/lib/materials/materialMethods/wavingBlocks.glsl"
#endif

//Program//
void main() {
	gl_Position = ftransform();

	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	#ifdef ATLAS_ROTATION
		texCoord += texCoord * float(hash33(mod(cameraPosition * 0.5, vec3(100.0))));
	#endif

	glColor = gl_Color;

	#if HAND_SWAYING > 0
		if (gl_ProjectionMatrix[2][2] > -0.5) {
			#include "/lib/misc/handSway.glsl"
		}
	#endif

	#if defined MIRROR_DIMENSION || defined WORLD_CURVATURE || defined WAVE_EVERYTHING
		vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
		#ifdef MIRROR_DIMENSION
			doMirrorDimension(position);
		#endif
		#ifdef WORLD_CURVATURE
			position.y += doWorldCurvature(position.xz);
		#endif
		#ifdef WAVE_EVERYTHING
			DoWaveEverything(position.xyz);
		#endif
		gl_Position = gl_ProjectionMatrix * gbufferModelView * position;
	#endif
}

#endif
