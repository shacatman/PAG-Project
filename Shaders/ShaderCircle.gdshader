shader_type canvas_item;

uniform bool active=true;
uniform bool show_red=false;
uniform bool show_green=false;
uniform bool show_blue=false;
uniform vec2 center;
uniform float size;//0.17 seems like a good choice
void fragment(){
//	if(!active){
//		return;
//	}
	vec2 scaleduv=UV-0.5;
	float mask =1.0-smoothstep(size-0.1,size,length(scaleduv-center));
	COLOR=texture(SCREEN_TEXTURE,SCREEN_UV);
	vec3 grayscale=vec3(COLOR.r+COLOR.g+COLOR.b)/3.0;
	bool setcolor=false;
	if(mask>0.85){
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
