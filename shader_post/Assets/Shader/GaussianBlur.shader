Shader "Unlit/GaussianBlur"
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;

				float4 uv01 : TEXCOORD1;	//一个vector4存储两个纹理坐标
				float4 uv23 : TEXCOORD2;	//一个vector4存储两个纹理坐标
				float4 uv45 : TEXCOORD3;	//一个vector4存储两个纹理坐标

                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			//XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height
			float4 _MainTex_TexelSize;
			//给一个offset，这个offset可以在外面设置，是我们设置横向和竖向blur的关键参数
			float4 _offsets;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//计算一个偏移值，offset可能是（0，1，0，0）也可能是（1，0，0，0）这样就表示了横向或者竖向取像素周围的点
				_offsets *= _MainTex_TexelSize.xyxy;

				//由于uv可以存储4个值，所以一个uv保存两个vector坐标，_offsets.xyxy * float4(1,1,-1,-1)可能表示(0,1,0-1)，表示像素上下两个
				//坐标，也可能是(1,0,-1,0)，表示像素左右两个像素点的坐标，下面*2.0，*3.0同理
				o.uv01 = v.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1);
				o.uv23 = v.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 2.0;
				o.uv45 = v.uv.xyxy + _offsets.xyxy * float4(1, 1, -1, -1) * 3.0;


                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 color = fixed4(0,0,0,0);
				//将像素本身以及像素左右（或者上下，取决于vertex shader传进来的uv坐标）像素值的加权平均
				color += 0.4 * tex2D(_MainTex, i.uv);
				color += 0.15 * tex2D(_MainTex, i.uv01.xy);
				color += 0.15 * tex2D(_MainTex, i.uv01.zw);
				color += 0.10 * tex2D(_MainTex, i.uv23.xy);
				color += 0.10 * tex2D(_MainTex, i.uv23.zw);
				color += 0.05 * tex2D(_MainTex, i.uv45.xy);
				color += 0.05 * tex2D(_MainTex, i.uv45.zw);
				return color;

	//————————————————
	//版权声明：本文为CSDN博主「puppet_master」的原创文章，遵循 CC 4.0 BY - SA 版权协议，转载请附上原文出处链接及本声明。
	//原文链接：https ://blog.csdn.net/puppet_master/article/details/52783179
 //               // sample the texture
 //               fixed4 col = tex2D(_MainTex, i.uv);
 //               // apply fog
 //               //UNITY_APPLY_FOG(i.fogCoord, col);
 //               return col;
            }
            ENDCG
        }
    }
}
