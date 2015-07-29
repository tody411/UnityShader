// LambertShader
Shader "Custom/LambertShader" {
    // LambertShader parameters.
    Properties {
        // Ambient.
        // _Ka: Ambient constant.
        _Ambient ("Ambient Color", Color) = (0.3,0.3,1,1)
        _Ka ("Ka", Range (0.01, 1)) = 0.5
        // Diffuse.
        // _Kd: Diffuse constant.
        _Diffuse ("Diffuse Color", Color) = (0.3,0.3,1,1)
        _Kd ("Kd", Range (0.01, 1)) = 0.8
    }
    SubShader {
    pass{
        Tags { "LightMode" = "ForwardBase" }

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

        // Properties for Cg program.
        float4 _Ambient;
        float  _Ka;
        float4 _Diffuse;
        float   _Kd;

        // Data from vertex shader (output) to pixel shader (input).
        struct vertexOutput {
            float4 pos : SV_POSITION; // Position
            float3 L   : TEXCOORD0; // Light vector
            float3 N   : TEXCOORD1; // Normal vector
        };

        // Vertex shader.
        vertexOutput vert(appdata_base v) : POSITION
        {
            vertexOutput output;

            output.pos = mul (UNITY_MATRIX_MVP, v.vertex);

            float3 N = v.normal;
            output.N = N;

            output.L = ObjSpaceLightDir(v.vertex);
            return output;
        }

        // Fragment shader.
        // Main Lambert shading process.
        float4 frag(vertexOutput input) : COLOR
        {
            float3 L = normalize( input.L );
            float3 N = normalize( input.N );

            float4 I_a = _Ka * _Ambient;

            float LdN = clamp( dot(L, N), 0, 1 );
            float4 I_d = _Kd * LdN * _Diffuse;

            float4 I = I_a + I_d;
            return I;
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}