Shader "Unlit/ColorAdjustEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1

		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
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

			half _Brightness;
			half _Saturation;
			half _Contrast;

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
                fixed4 col = tex2D(_MainTex, i.uv);

			    //col = col * _Brightness;
				fixed3 finalColor = col * _Brightness;
				//saturation饱和度：首先根据公式计算同等亮度情况下饱和度最低的值：
				fixed gray = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
				fixed3 grayColor = fixed3(gray, gray, gray);

				//根据Saturation在饱和度最低的图像和原图之间差值
				finalColor = lerp(grayColor, finalColor, _Saturation);

				//contrast对比度：首先计算对比度最低的值
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				//根据Contrast在对比度最低的图像和原图之间差值
				finalColor = lerp(avgColor, finalColor, _Contrast);

			

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;
				return fixed4(finalColor, col.a);
            }
            ENDCG
        }
    }
}
