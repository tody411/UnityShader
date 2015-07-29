// ToonShader
Shader "Custom/ToonShader" {
    // ToonShader parameters.
    Properties {
        // Ambient color.
        _Ambient ("Ambient Color", Color) = (0.1,0.1, 0.4,1)
        // Diffuse color.
        // Border: Border between ambient and diffuse colors.
        // BorderBlur: Smoothness of the border boundary.
        _Diffuse ("Diffuse Color", Color) = (0.3,0.3,1,1)
        _DiffuseBorder ("Diffuse border", Range (0.01, 1)) = 0.2
        _DiffuseBorderBlur ("Diffuse border blur", Range (0.01, 0.2)) = 0.01
        // Specular color.
        // Border: Border between specular and darker (ambient, diffuse) colors.
        // BorderBlur: Smoothness of the border boundary.
        _Specular ("Spec Color", Color) = (1,1,1,1)
        _SpecularBorder ("Specular border", Range (0.01, 1)) = 0.5
        _SpecularBorderBlur ("Specular border blur", Range (0.01, 0.2)) = 0.01
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
    }
    SubShader {
    pass{
        Tags { "LightMode" = "ForwardBase" }

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        // Properties for Cg program.
        float4  _Ambient;
        float4  _Diffuse;
        float   _DiffuseBorder;
        float   _DiffuseBorderBlur;
        float4  _Specular;
        float   _SpecularBorder;
        float   _SpecularBorderBlur;
        float _Shininess;

        // Data from vertex shader (output) to pixel shader (input).
        struct vertexOutput {
            float4 pos : SV_POSITION; // Position.
            float3 L   : TEXCOORD0; // Light vector.
            float3 N   : TEXCOORD1; // Normal vector.
            float3 RV   : TEXCOORD2; // Reflected view vector.
        };

        // Vertex shader.
        vertexOutput vert(appdata_base v) : POSITION
        {
            vertexOutput output;

            output.pos = mul (UNITY_MATRIX_MVP, v.vertex);

            float3 N = v.normal;
            output.N = N;

            output.L = ObjSpaceLightDir(v.vertex);

            float3 V = ObjSpaceViewDir(v.vertex);
            output.RV = reflect(-V, N);
            return output;
        }

        // Pixel shader.
        // 1. Compute illumination.
        // 2. Continuous illumination is converted to reduced colors.
        float4 frag(vertexOutput input) : COLOR
        {
            // Compute illumination.
            float3 L = normalize( input.L );
            float3 N = normalize( input.N );
            float3 RV = normalize( input.RV );

            float LdN = clamp( dot(L, N), 0, 1 );
            float I_d = LdN;

            float LdRV = clamp( dot(L, RV), 0, 1 );
            float shininess = pow(500.0, _Shininess);
            float I_s = pow( LdRV, shininess);

            // Color mapping.
            float4 c_a = _Ambient;

            float t_d = smoothstep( _DiffuseBorder - _DiffuseBorderBlur, _DiffuseBorder + _DiffuseBorderBlur, I_d);
            float4 c_d = lerp(c_a, _Diffuse, t_d);

            float t_s = smoothstep(_SpecularBorder - _SpecularBorderBlur, _SpecularBorder + _SpecularBorderBlur, I_s);
            float4 c = lerp(c_d, _Specular, t_s);
            return c;
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}