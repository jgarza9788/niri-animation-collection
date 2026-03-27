# GLSL Helper Snippets

This file contains reusable GLSL snippets for animation, easing, UV transforms, shapes, and general shader utilities.
These are designed to be dropped into custom shaders (e.g., Niri animations) to speed up development and keep things consistent.

---

## 🧠 Utility / Math Helpers

```glsl
// Clamp between 0 and 1 (very common in shaders)
float saturate(float x) {
    return clamp(x, 0.0, 1.0);
}

// Remap a value from one range to another
float remap(float value, float inMin, float inMax, float outMin, float outMax) {
    float t = (value - inMin) / (inMax - inMin);
    return mix(outMin, outMax, t);
}

// Smooth remap (uses smoothstep for softer transitions)
float remapSmooth(float value, float inMin, float inMax, float outMin, float outMax) {
    float t = smoothstep(inMin, inMax, value);
    return mix(outMin, outMax, t);
}
```

---

## 🎯 Step / Sharpening Functions

```glsl
// Push values toward 0 or 1 (reduces "middle mush")
float sharpen(float t, float strength) {
    // strength > 1.0 = sharper contrast
    return pow(t, strength) / (pow(t, strength) + pow(1.0 - t, strength));
}

// Hard threshold (binary)
float hardStep(float t, float threshold) {
    return t < threshold ? 0.0 : 1.0;
}

// Soft threshold
float softStep(float t, float edge0, float edge1) {
    return smoothstep(edge0, edge1, t);
}
```

---

## 📏 Distance / Shapes

```glsl
// Distance from center (0.5, 0.5)
float distFromCenter(vec2 uv) {
    return length(uv - vec2(0.5));
}

// Circle mask (1 inside, 0 outside)
float circle(vec2 uv, vec2 center, float radius) {
    return step(length(uv - center), radius);
}

// Smooth circle (soft edge)
float smoothCircle(vec2 uv, vec2 center, float radius, float blur) {
    float d = length(uv - center);
    return smoothstep(radius, radius - blur, d);
}

// Rectangle mask
float rect(vec2 uv, vec2 min, vec2 max) {
    return step(min.x, uv.x) * step(min.y, uv.y) *
           step(uv.x, max.x) * step(uv.y, max.y);
}
```

---

## 🔄 UV Transform Helpers

```glsl
// Scale UV around a pivot
vec2 scaleUV(vec2 uv, vec2 pivot, vec2 scale) {
    return (uv - pivot) / scale + pivot;
}

// Rotate UV around a pivot
vec2 rotateUV(vec2 uv, vec2 pivot, float angle) {
    float s = sin(angle);
    float c = cos(angle);

    uv -= pivot;
    uv = mat2(c, -s, s, c) * uv;
    uv += pivot;

    return uv;
}

// Translate UV
vec2 translateUV(vec2 uv, vec2 offset) {
    return uv + offset;
}

// Zoom (scale from center 0.5, 0.5)
vec2 zoomUV(vec2 uv, float zoom) {
    return (uv - 0.5) / zoom + 0.5;
}
```

---

## 🌊 Distortion / Effects

```glsl
// Wave distortion (horizontal)
vec2 waveX(vec2 uv, float strength, float frequency, float time) {
    uv.x += sin(uv.y * frequency + time) * strength;
    return uv;
}

// Wave distortion (vertical)
vec2 waveY(vec2 uv, float strength, float frequency, float time) {
    uv.y += sin(uv.x * frequency + time) * strength;
    return uv;
}

// Radial ripple
vec2 ripple(vec2 uv, vec2 center, float strength, float frequency, float time) {
    vec2 dir = uv - center;
    float dist = length(dir);

    float wave = sin(dist * frequency - time) * strength;
    return uv + normalize(dir) * wave;
}
```

---

## 🎨 Color Helpers

```glsl
// Simple gradient between two colors
vec4 gradient(vec2 uv, vec4 colorA, vec4 colorB) {
    return mix(colorA, colorB, uv.y);
}

// Multiply brightness
vec4 brightness(vec4 color, float amount) {
    return vec4(color.rgb * amount, color.a);
}

// Tint color
vec4 tint(vec4 color, vec3 tintColor, float strength) {
    return vec4(mix(color.rgb, tintColor, strength), color.a);
}
```

---

## ⏱️ Animation Helpers

```glsl
// Ping-pong (0 → 1 → 0)
float pingPong(float t) {
    return abs(fract(t * 2.0) - 1.0);
}

// Loop (0 → 1 repeating)
float loop(float t) {
    return fract(t);
}

// Delay start of animation
float delay(float t, float delayAmount) {
    return saturate((t - delayAmount) / (1.0 - delayAmount));
}

// Reverse animation
float reverse(float t) {
    return 1.0 - t;
}
```

---

## 🧩 Mask Blending

```glsl
float blendAdd(float a, float b) {
    return clamp(a + b, 0.0, 1.0);
}

float blendMultiply(float a, float b) {
    return a * b;
}

float blendSubtract(float a, float b) {
    return clamp(a - b, 0.0, 1.0);
}
```

---

## ⭐ Star Shape (Sharp, No Curves)

```glsl
// Sharp star (configurable points)
float star(vec2 uv, vec2 center, float size, int points) {
    vec2 p = uv - center;
    float angle = atan(p.y, p.x);
    float radius = length(p);

    float slice = 6.28318530718 / float(points);
    float d = cos(floor(0.5 + angle / slice) * slice - angle) * radius;

    return step(d, size);
}
```

---

## 🎯 Easing Functions

```glsl
// Exponential
float easeInExpo(float t) {
    return t == 0.0 ? 0.0 : pow(2.0, 10.0 * (t - 1.0));
}
float easeOutExpo(float t) {
    return t == 1.0 ? 1.0 : 1.0 - pow(2.0, -10.0 * t);
}

// Sine
float easeInSine(float t) {
    return 1.0 - cos((t * 3.141592653589793) / 2.0);
}
float easeOutSine(float t) {
    return sin((t * 3.141592653589793) / 2.0);
}

// Cubic
float easeInCubic(float t) {
    return t * t * t;
}
float easeOutCubic(float t) {
    float f = t - 1.0;
    return f * f * f + 1.0;
}
```

---

## 🧪 Example Usage (Niri-style)

```glsl
float t = niri_clamped_progress;

// Apply easing
float eased = easeOutExpo(t);

// Scale window from center
vec2 uv2 = scaleUV(coords_geo.xy, vec2(0.5), vec2(eased));

// Fade in
float alpha = eased;

// Final output
return vec4(color.rgb, color.a * alpha);
```

---

## Notes

* Most helpers assume UV space is **0.0 → 1.0**
* `vec2(0.5)` is typically the center
* Combine easing + UV transforms for most animation effects
* Prefer `smoothstep` over `step` for anything visible to users (avoids harsh edges)

---
