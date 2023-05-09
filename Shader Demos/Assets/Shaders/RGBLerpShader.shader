Shader "Unlit/RGBLerpShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _ColorPoint1("Color 1", Color) = (1.0, 1.0, 0.0)
        _ColorPoint2("Color 2", Color) = (0.0, 1.0, 1.0)
        _ColorPoint3("Color 3", Color) = (1.0, 0.0, 1.0)

        _ColorSpeed("Color Switching Speed",float) = 1

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

            float _ColorSpeed;

            fixed3 _ColorPoint1;
            fixed3 _ColorPoint2;
            fixed3 _ColorPoint3;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 linearInterpolationWithWrapAround(float scroll)
            {
                float numColors = 3.0;
                fixed3 lerpedColor;

                float midpointValue = 1.0 / numColors;
                if (scroll < midpointValue) {
                    lerpedColor = (scroll - 0.0) * _ColorPoint1 + (midpointValue - scroll) * _ColorPoint3;
                }
                else if (scroll < midpointValue * 2) {
                    lerpedColor = (scroll - midpointValue) * _ColorPoint2 + (2*midpointValue - scroll) * _ColorPoint1;
                }
                else {
                    lerpedColor = (scroll - (2*midpointValue)) * _ColorPoint3 + (1.0 - scroll) * _ColorPoint2;
                }

                return fixed4(lerpedColor, 1);
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // Sample the relative luminance (y) of the texture
                fixed4 y = 0.299 * tex2D(_MainTex, i.uv).r + 0.587 * tex2D(_MainTex, i.uv).g + 0.114 * tex2D(_MainTex, i.uv).b;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                float scroll = frac(y + _Time.x * _ColorSpeed);

                fixed4 col = linearInterpolationWithWrapAround(scroll);
                
                return col;
            }
            ENDCG
        }
    }
}
