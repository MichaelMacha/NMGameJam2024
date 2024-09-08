shader_type canvas_item;

uniform sampler2D tile;
uniform float repeats = 1.0;
uniform vec2 offset = vec2(0.0, 0.0);

void fragment() {
	COLOR = texture(TEXTURE,
		mod(
			UV,
			vec2(1)/repeats) + offset
		* repeats);
}
//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
