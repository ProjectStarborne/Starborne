shader_type canvas_item;

uniform float time;  // Passed in as time progresses
uniform float intensity : hint_range(0.1, 5.0) = 1.0;
uniform float pixel_size : hint_range(1.0, 10000.0) = 6000.0;  // Higher value = smaller pixels
uniform float star_speed : hint_range(0.01, 0.1) = 0.02;  // Very slow speed for the stars
uniform float star_density : hint_range(0.1, 5.0) = 1.0;  // Very low density of stars

void fragment() {
    // Get local UV coordinates (0 to 1)
    vec2 uv = UV;

    // Scale UV to apply pixelation
    vec2 scaled_uv = floor(uv * pixel_size) / pixel_size;

    // Create patterns based on scaled UV
    float wave = sin((scaled_uv.x * 5.0 + scaled_uv.y * 5.0 + time) * 3.0) * 0.5 + 0.5;
    float noise = fract(sin(dot(scaled_uv * 15.0, vec2(12.9898, 78.233))) * 43758.5453);

    // Mix the wave and noise for dynamic shifting
    float effect = mix(wave, noise, 0.6);

    // Generate colors with a darker, space-inspired palette
    vec3 color = vec3(
        0.05 + 0.1 * sin(time * 2.0 + scaled_uv.x * 8.0),   // Deep purple tones
        0.02 + 0.08 * cos(time * 1.5 + scaled_uv.y * 8.0),  // Dark blues
        0.03 + 0.1 * effect                                // Subtle grayish-blue effect
    );

    // Add a few drifting stars
    vec2 star_pos = uv - vec2(0.0, mod(time * star_speed, 1.0));  // Very slow, vertical star movement
    float star_pattern = fract(sin(dot(star_pos * star_density, vec2(12.9898, 78.233))) * 43758.5453);
    float star_brightness = step(0.9995, star_pattern);  // Extremely high threshold for very few stars
    color += vec3(star_brightness);  // Add stars as bright white dots

    // Apply intensity to the color
    color *= intensity;

    // Clamp colors to stay within the "space" theme
    color = clamp(color, 0.0, 0.2);  // Ensures colors remain in the dark spectrum

    COLOR = vec4(color, 1.0);
}
