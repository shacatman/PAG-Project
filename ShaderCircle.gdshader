shader_type canvas_item;

uniform bool active=true;
uniform vec2 center;
uniform float size;
void fragment(){
	
	float ratio= SCREEN_PIXEL_SIZE.x/ SCREEN_PIXEL_SIZE.y;
	vec2 scaleduv=UV-0.5;//(SCREEN_UV-vec2(0.5,0.0))/ vec2(ratio,1.0)+vec2(0.5,0.0);
	float mask =1.0-smoothstep(size-0.1,size,length(scaleduv-center));
	COLOR=texture(SCREEN_TEXTURE,SCREEN_UV);
	vec3 grayscale=vec3(COLOR.r+COLOR.g+COLOR.b)/3.0;
	bool setcolor=false;
	if(mask>0.7){//0.7
		if(COLOR.g>0.5 && COLOR.r<0.5 && COLOR.b<0.5){
			COLOR.rgb=COLOR.rgb*vec3(mask);
			setcolor=true;
		}
	}
	if(!setcolor)
		COLOR.rgb=vec3(grayscale);
}

/*shader_type canvas_item;

uniform bool active=true;
uniform vec2 center;
uniform float size;
void fragment(){
	
	float ratio= SCREEN_PIXEL_SIZE.x/ SCREEN_PIXEL_SIZE.y;
	vec2 scaleduv=UV-0.5;//(SCREEN_UV-vec2(0.5,0.0))/ vec2(ratio,1.0)+vec2(0.5,0.0);
	float mask =1.0-smoothstep(size-0.1,size,length(scaleduv-center));
	COLOR=texture(SCREEN_TEXTURE,SCREEN_UV);
	vec3 grayscale=vec3(COLOR.r+COLOR.g+COLOR.b)/3.0;
	if(mask>0.7)//0.7
	COLOR.rgb=COLOR.rgb*vec3(mask);
	else
	COLOR.rgb=vec3(grayscale);
}*/