Shader "Unlit/PaletteCyclingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientTex("Color Gradient Image", 2D) = "white" {}

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

            sampler2D _GradientTex;
            float _ColorSpeed;

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
                // Sample the relative luminance (y) of the texture
                fixed4 y = 0.299 * tex2D(_MainTex, i.uv).r + 0.587 * tex2D(_MainTex, i.uv).g + 0.114 * tex2D(_MainTex, i.uv).b;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                float scroll = frac(y + _Time.x * _ColorSpeed);

                fixed4 color = tex2D(_GradientTex, float2(scroll, 0.5));
                
                return color;
            }
            ENDCG
        }
    }
}
