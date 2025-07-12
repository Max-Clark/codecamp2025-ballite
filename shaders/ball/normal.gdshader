shader_type canvas_item;

void fragment() {
   vec4 original = texture(TEXTURE, UV);

   // Create radial distance for sphere lighting
   vec2 center = vec2(0.5, 0.5);
   float dist = distance(UV, center);

   // Base black color
   vec3 base_color = vec3(0.1, 0.1, 0.1);

   // Light source from top-left
   vec2 light_pos = vec2(0.3, 0.3);
   float light_dist = distance(UV, light_pos);

   // Highlight calculation
   float highlight = 1.0 - smoothstep(0.0, 0.3, light_dist);
   highlight = pow(highlight, 3.0);

   // Rim lighting for sphere effect
   float rim = 1.0 - smoothstep(0.3, 0.5, dist);
   rim = pow(rim, 2.0);

   // Combine lighting
   vec3 final_color = base_color + highlight * 0.4 + rim * 0.2;

   COLOR = vec4(final_color, original.a);
}