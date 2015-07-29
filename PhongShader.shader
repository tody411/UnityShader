// Pixel処理でシェーディング計算を行うPhongShader
Shader "Custom/PhongShader" {
    // PhongShaderのパラメータを宣言
    Properties {
        // 環境光の色
        // _Ka: 反射率
        _Ambient ("Ambient Color", Color) = (0.3,0.3,1,1)
        _Ka ("Ka", Range (0.01, 1)) = 0.5
        // 拡散反射の色
        // _Kd: 反射率
        _Diffuse ("Diffuse Color", Color) = (0.3,0.3,1,1)
        _Kd ("Kd", Range (0.01, 1)) = 0.8
        // 鏡面反射の色
        // _Ks: 反射率
        // _Shininess: ハイライトの鋭さ
        _Specular ("Spec Color", Color) = (1,1,1,1)
        _Ks ("Ks", Range (0.01, 1)) = 1.0
        _Shininess ("Shininess", Range (0.01, 1)) = 0.7
    }
    SubShader {
    pass{
        // Unityのライトオブジェクトを使ったLightMode
        Tags { "LightMode" = "ForwardBase" }
        // Cgプログラムを使用する宣言
        // 頂点処理とピクセル処理を行うことを宣言
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        // Cgプログラムで使う変数
        // Propertiesブロックと対応付ける
        float4 _Ambient;
        float  _Ka;
        float4 _Diffuse;
        float   _Kd;
        float4 _Specular;
        float   _Ks;
        float _Shininess;
        // 頂点からピクセルに転送されるデータ
        struct vertexOutput {
            float4 pos : SV_POSITION; // 座標変換後の位置
            float3 L   : TEXCOORD0; // ライトベクトル
            float3 N   : TEXCOORD1; // 法線ベクトル
            float3 RV   : TEXCOORD2; // 視線の正反射ベクトル
        };
        // 頂点毎の処理
        // pos, L, N, RVのデータを計算する．
        vertexOutput vert(appdata_base v) : POSITION
        {
            vertexOutput output;
            // 座標変換後の位置
            output.pos = mul (UNITY_MATRIX_MVP, v.vertex);
            // 法線ベクトル
            float3 N = v.normal;
            output.N = N;
            // ライトベクトル
            output.L = ObjSpaceLightDir(v.vertex);
            // 視線の正反射ベクトル
            float3 V = ObjSpaceViewDir(v.vertex);
            output.RV = reflect(-V, N);
            return output;
        }
        // ピクセル毎の処理
        // PhongShadingのライティング計算を行う
        float4 frag(vertexOutput input) : COLOR
        {
            // 頂点処理で計算したベクトルデータを正規化して取り出す
            float3 L = normalize( input.L );
            float3 N = normalize( input.N );
            float3 RV = normalize( input.RV );
            // 環境光成分I_aを計算
            float4 I_a = _Ka * _Ambient;
            // 拡散反射成分I_dを計算
            float LdN = clamp( dot(L, N), 0, 1 );
            float4 I_d = _Kd * LdN * _Diffuse;
            // 鏡面反射成分I_sを計算
            float LdRV = clamp( dot(L, RV), 0, 1 );
            float shininess = pow(500.0, _Shininess);
            float4 I_s = _Ks * pow( LdRV, shininess) * _Specular;
            // 足し合わせて最終的な色を計算する
            float4 I = I_a + I_d + I_s;
            return I;
        }
        ENDCG
        }
    }
    FallBack "Diffuse"
}