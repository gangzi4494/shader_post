Shader "Unlit/DistortPostEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	    _NoiseTex("Base (RGB)", 2D) = "black" {}//默认给黑色，也就是不会偏移
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			uniform sampler2D _NoiseTex;
			uniform float _DistortTimeFactor;
			uniform float _DistortStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

				//根据时间改变采样噪声图获得随机的输出
				float4 noise = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortTimeFactor);
				//以随机的输出*控制系数得到偏移值
				float2 offset = noise.xy * _DistortStrength;
				//像素采样时偏移offset
				float2 uv = offset + i.uv;


                fixed4 col = tex2D(_MainTex, uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
