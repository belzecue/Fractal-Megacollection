﻿Shader "Fractals/Coloring Techniques/Edge Detection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_Iter ("Iterations", Range(0, 2500)) = 100
		
		_Zoom ("Zoom", Range (0.1, 1000)) = .65
		_Position ("Offset", Vector) = (0.4, 0, 0, 0)

		_Thickness ("Dividend", Range(0.1, 20)) = 2000

		_Interior ("Interior", Color) = (1, 1, 1, 1)
		_Edge ("Edge", Color) = (0, 0, 0, 0)
	}	
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Complex.cginc"
			#include "FractalOperations.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;

			int _Iter;

			fixed _Zoom;
			float2 _Position;

			fixed _Thickness;

			fixed4 _Interior;
			fixed4 _Edge;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float x0 = (ClampScaleX(i.uv) + _Position.x) / _Zoom;
				float y0 = (ClampScaleY(i.uv) + _Position.y) / _Zoom;
				
				int iteration = 0;

				float2 z = float2(x0, y0);
				float2 d = float2(1, 1); //Derivative in regards to Z
				float2 c = float2(x0, y0);

				while (IsBounded(z, 4) && iteration < _Iter)
				{
					if (cabs(z) < cabs(0.001 * cmul(_Thickness, d)))
					{
						return _Edge;
					}

					d = 2 * cmul(d, z);	

					z = cmul(z, z);
					z += c;					

					iteration++;
				}
				
				return _Interior;
			}		    
			ENDCG
		}
	}
	CustomEditor "FractalEditor"
}
