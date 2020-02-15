Shader "Unlit/SimpleBlurEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;

				float2 uv1 : TEXCOORD1;  //周围纹理1
				float2 uv2 : TEXCOORD2;  //周围纹理2
				float2 uv3 : TEXCOORD3;  //周围纹理3
				float2 uv4 : TEXCOORD4;  //周围纹理4

                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


			float4 _MainTex_TexelSize;

			float _BlurRadius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				//计算uv上下左右四个点对于blur半径下的uv坐标
				o.uv1 = v.texcoord.xy + _BlurRadius * _MainTex_TexelSize * float2(1, 1);
				o.uv2 = v.texcoord.xy + _BlurRadius * _MainTex_TexelSize * float2(-1, 1);
				o.uv3 = v.texcoord.xy + _BlurRadius * _MainTex_TexelSize * float2(-1, -1);
				o.uv4 = v.texcoord.xy + _BlurRadius * _MainTex_TexelSize * float2(1, -1);

				/*o.uv1 = v.texcoord.xy + _BlurRadius * float2(1, 1);
				o.uv2 = v.texcoord.xy + _BlurRadius * float2(-1, 1);
				o.uv3 = v.texcoord.xy + _BlurRadius * float2(-1, -1);
				o.uv4 = v.texcoord.xy + _BlurRadius * float2(1, -1);*/


                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 color = tex2D(_MainTex, i.uv);

				color += tex2D(_MainTex, i.uv1);
				color += tex2D(_MainTex, i.uv2);
				color += tex2D(_MainTex, i.uv3);
				color += tex2D(_MainTex, i.uv4);

				//color = color * 0.2;
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
				return color * 0.2;
            }
            ENDCG
        }
    }
}
