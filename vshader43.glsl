/***************************
 * File: vshader42.glsl:
 *   A simple vertex shader.
 *
 * - Vertex attributes (positions & colors) for all vertices are sent
 *   to the GPU via a vertex buffer object created in the OpenGL program.
 *
 * - This vertex shader uses the Model-View and Projection matrices passed
 *   on from the OpenGL program as uniform variables of type mat4.
 ***************************/

#version 150 // YJC: Comment/un-comment this line to resolve compilation errors
                 //      due to different settings of the default GLSL version

in  vec4 vPosition;
in  vec3 vNormal;
out vec4 color;

uniform int smooth_shading; // use smooth/flat shading
uniform int point_light; // use point/spotlight source
uniform mat4 model_view;
uniform mat4 projection;
// var for directional light
uniform vec4 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform vec4 distant_light_dir;

// var for point light
uniform vec4 pointAmbientProduct, pointDiffuseProduct, pointSpecularProduct;
uniform vec4 pointLightDir;
uniform float pointLightAng;	// Must be in radian
uniform vec4 pointLightPosition;   // Must be in Eye Frame
uniform float pointLightExp;
uniform float ConstAtt;  // Constant Attenuation
uniform float LinearAtt; // Linear Attenuation
uniform float QuadAtt;   // Quadratic Attenuation

uniform mat3 Normal_Matrix;

uniform float Shininess;


void main() 
{
	// Transform vertex  position into eye coordinates
	vec3 pos,L,E,H,N,Lf;
	vec4 ambient, diffuse, specular;
	float d,s, dis, attenuation;
    pos = (model_view * vPosition).xyz;
    L = normalize( -distant_light_dir.xyz);
    E = normalize( -pos );
    H = normalize( L +  E );
	if(smooth_shading == 0) N = normalize(Normal_Matrix * vNormal);
	else{
		N = Normal_Matrix * vPosition.xyz;
		N = normalize(N);
	}
	/* for light source 1*/
	ambient = AmbientProduct;
	d = max( dot(L, N), 0.0 );
    diffuse = d * DiffuseProduct;
	s = pow( max(dot(N, H), 0.0), Shininess );
    specular = s * SpecularProduct;
	if( dot(L, N) < 0.0 ) {
		specular = vec4(0.0, 0.0, 0.0, 1.0);
    } 
	color = (ambient + diffuse + specular);

	/* for light source 2*/
	L = normalize( pointLightPosition.xyz - pos );
	if(point_light == 0){
		Lf = normalize(pointLightDir.xyz);
	}
	H = normalize( L +  E );
	// get distance attenuation
	dis = length(pos-pointLightPosition.xyz);
	attenuation = 1/(ConstAtt + LinearAtt*dis + QuadAtt*dis*dis);
	
	ambient = attenuation * pointAmbientProduct;
	d = max( dot(L, N), 0.0 );
	diffuse = attenuation * d * pointDiffuseProduct;
	// get specular light
	s = pow( max(dot(N, H), 0.0), Shininess );
	if(point_light == 0){	
		//attenuation *= pow(1,pointLightExp);
		if(dot(-L,Lf)>cos(pointLightAng)){
			attenuation *= pow(dot(-L,Lf),pointLightExp);
		}
		else{
			attenuation = 0;
		}
	}
	specular = attenuation*s*pointSpecularProduct;
	if( dot(L, N) < 0.0 ) {
		specular = vec4(0.0, 0.0, 0.0, 1.0);
    } 
	color += (ambient + diffuse + specular);
	
	gl_Position = projection * model_view * vPosition;
} 