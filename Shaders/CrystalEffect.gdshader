shader_type canvas_item;

uniform bool active=true;
uniform float red=1f;
uniform float green=0f;
uniform float blue=0f;
uniform vec2 center;
uniform float size;//0.17 seems like a good choice

float hue(float r,float g, float b){//hue value calculation formula
	float hue;
	float minval=min(r,min(g,b));
	float maxval=max(r,max(g,b));
	if(maxval==minval){
		hue=0f;
	}
	else{
		if(maxval == r) {
	        hue = (g - b) / (maxval - minval);
	    } else if(maxval == g) {
	        hue = 2f + (b - r) / (maxval - minval);
	    } else {
	        hue = 4f + (r - g) / (maxval - minval);
	    }
	    hue = hue * 60f;
	    if(hue < 0f) hue = hue + 360f;
	}
	return hue;
}


void fragment(){
	if(!active){//unused currently
		discard;//ignore the crystal effect when not needed
	}
	vec2 scaleduv=UV-0.5;//center the effect
//	float rsize=size+0.1*size*sin(TIME*0.5);//option for changing effect radius
	float mask =1.0-smoothstep(size-0.1,size,length(scaleduv-center));
	COLOR=texture(SCREEN_TEXTURE,SCREEN_UV);
//	vec3 grayscale=vec3(COLOR.r+COLOR.g+COLOR.b)/3.0;
	vec3 grayscale=vec3(COLOR.r*0.2126+COLOR.g*0.7152+COLOR.b*0.0722);//better difference between the colors
	bool setcolor=false;
	if(mask>0.85){//inside the effect area
		float pixel_hue=hue(COLOR.r,COLOR.g,COLOR.b);
		float crystal_hue=hue(red,green,blue);
		if(abs(pixel_hue-crystal_hue)>50f){//not same color as crystal- apply crystal color
			COLOR.rgb=(grayscale+vec3(red,green,blue))*vec3(mask)/2f;//average value between the grayscale and crystal color
			COLOR.a=0.5;//make the color transperent
		}
		setcolor=true;
	}
	if(!setcolor)
		discard;
}