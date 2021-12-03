shader_type canvas_item;

uniform bool active=true;
uniform bool show_red=false;
uniform bool show_green=true;
uniform bool show_blue=true;
uniform vec2 center;
uniform float size;//0.17 seems like a good choice
void fragment(){
	
//	float ratio= SCREEN_PIXEL_SIZE.x/ SCREEN_PIXEL_SIZE.y;
	vec2 scaleduv=UV-0.5;//(SCREEN_UV-vec2(0.5,0.0))/ vec2(ratio,1.0)+vec2(0.5,0.0);
	float mask =1.0-smoothstep(size-0.1,size,length(scaleduv-center));
	COLOR=texture(SCREEN_TEXTURE,SCREEN_UV);
	vec3 grayscale=vec3(COLOR.r+COLOR.g+COLOR.b)/3.0;
	bool setcolor=false;
	if(mask>0.85){//0.7
		//determine the hue value of the pixel
		float hue;
		float minval=min(COLOR.r,min(COLOR.g,COLOR.b));
		float maxval=max(COLOR.r,max(COLOR.g,COLOR.b));
		if(maxval==minval){
			hue=0f;
		}
		else{
			if(maxval == COLOR.r) {
		        hue = (COLOR.g - COLOR.b) / (maxval - minval);
		    } else if(maxval == COLOR.g) {
		        hue = 2f + (COLOR.b - COLOR.r) / (maxval - minval);
		    } else {
		        hue = 4f + (COLOR.r - COLOR.g) / (maxval - minval);
		    }
		    hue = hue * 60f;
		    if(hue < 0f) hue = hue + 360f;
		}
		
		//show red spectrum
		if(show_red && ( hue>=340f || hue<25f)){
			COLOR.rgb=COLOR.rgb*vec3(mask);
			setcolor=true;
		}
		//show green spectrum
		if(show_green && hue>=75f && hue<155f){
			COLOR.rgb=COLOR.rgb*vec3(mask);
			setcolor=true;
		}
		//show blue spectrum
		if(show_blue && hue>=155f && hue<255f){
			COLOR.rgb=COLOR.rgb*vec3(mask);
			setcolor=true;
		}
	}
	if(!setcolor)
		COLOR.rgb=vec3(grayscale);
}



/////////////////////////////PREVIOUS VERSION- working with green only
/*shader_type canvas_item;

uniform bool active=true;
uniform bool show_green=false;
uniform vec2 center;
uniform float size;
void fragment(){
	
//	float ratio= SCREEN_PIXEL_SIZE.x/ SCREEN_PIXEL_SIZE.y;
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
}*/

/*OLDEST VERSION
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
	if(mask>0.7)//0.7
	COLOR.rgb=COLOR.rgb*vec3(mask);
	else
	COLOR.rgb=vec3(grayscale);
}*/