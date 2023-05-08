Shader "Unlit/TransformationsShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _ScrollToggle("Toggle Scrolling", int) = 0
        _VerticalAmplitude("Vertical Translate Amplitude", float) = 1
        _VerticalCycleSpeed("Vertical Translate Speed", float) = 0
        _HorizontalAmplitude("Horizontal Translate Amplitude", float) = 1
        _HorizontalCycleSpeed("Horizontal Translate Speed", float) = 0
        _CyclePhaseShift("Cycle Phase Shift", Range(0, 6.2832)) = 0 // pi/2 and 3pi/2 make it travel in a circlular path

        _hcToggle("Toggle Horizontal Curve", int) = 0
        _hcOscillationAmplitude("Horizontal Curve Oscillation Amplitude", float) = 0.1
        _hcOscillationPeriod("Horizontal Curve Oscillation Period", float) = 5
        _hcOscillationSpeed("Horizontal Curve Oscillation Speed", float) = 50

        _hsToggle("Toggle Horizontal Stretch", int) = 0
        _hsOscillationAmplitude("Horizontal Stretch Oscillation Amplitude", float) = 0.1
        _hsOscillationPeriod("Horizontal Stretch Oscillation Period", float) = 5
        _hsOscillationSpeed("Horizontal Stretch Oscillation Speed", float) = 50

        _vcToggle("Toggle Vertical Curve", int) = 0
        _vcOscillationAmplitude("Vertical Curve Oscillation Amplitude", float) = 0.1
        _vcOscillationPeriod("Vertical Curve Oscillation Period", float) = 5
        _vcOscillationSpeed("Vertical Curve Oscillation Speed", float) = 50

        _vsToggle("Toggle Vertical Stretch", int) = 0
        _vsOscillationAmplitude("Vertical Stretch Oscillation Amplitude", float) = 0.1
        _vsOscillationPeriod("Vertical Stretch Oscillation Period", float) = 5
        _vsOscillationSpeed("Vertical Stretch Oscillation Speed", float) = 50

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

            int _ScrollToggle;
            float _VerticalAmplitude;
            float _VerticalCycleSpeed;
            float _HorizontalAmplitude;
            float _HorizontalCycleSpeed;
            float _CyclePhaseShift; // pi/2 and 3pi/2 make it go in a circle

            int _hcToggle;
            float _hcOscillationAmplitude;
            float _hcOscillationPeriod;
            float _hcOscillationSpeed;
            
            int _hsToggle;
            float _hsOscillationAmplitude;
            float _hsOscillationPeriod;
            float _hsOscillationSpeed;
            
            int _vcToggle;
            float _vcOscillationAmplitude;
            float _vcOscillationPeriod;
            float _vcOscillationSpeed;
            
            int _vsToggle;
            float _vsOscillationAmplitude;
            float _vsOscillationPeriod;
            float _vsOscillationSpeed;

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

                if (_hcToggle != 0) {
                    float2 horizontalCurveOscillationOffset = float2
                        (_hcOscillationAmplitude * sin(_hcOscillationPeriod * i.uv.y + _Time.x * _hcOscillationSpeed),
                        0);
                    i.uv += horizontalCurveOscillationOffset;
                }

                if (_hsToggle != 0) {
                    float2 horizontalStretchOscillationOffset = float2
                        (_hsOscillationAmplitude * sin(_hsOscillationPeriod * i.uv.x + _Time.x * _hsOscillationSpeed),
                        0);
                    i.uv += horizontalStretchOscillationOffset;
                }

                if (_vcToggle != 0) {
                    float2 verticalCurveOscillationOffset = float2
                        (0,
                        _vcOscillationAmplitude * sin(_vcOscillationPeriod * i.uv.x + _Time.x * _vcOscillationSpeed));
                    i.uv += verticalCurveOscillationOffset;
                }

                if (_vsToggle != 0) {
                    float2 verticalStretchOscillationOffset = float2
                        (0, 
                        _vsOscillationAmplitude * sin(_vsOscillationPeriod * i.uv.y + _Time.x * _vsOscillationSpeed));
                    i.uv += verticalStretchOscillationOffset;
                }

                if (_ScrollToggle != 0) {
                    float2 scrollingOffset = float2(
                        _HorizontalAmplitude * sin(_HorizontalCycleSpeed * (_Time.x + _CyclePhaseShift)),
                        _VerticalAmplitude * sin(_VerticalCycleSpeed * _Time.x));
                    i.uv += scrollingOffset;
                }

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
