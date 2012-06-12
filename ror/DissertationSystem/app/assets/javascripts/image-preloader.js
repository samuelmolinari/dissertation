$(document).ready(function(){
	image = new Image();
	
	urls = [
		"/images/loader/photo-rendering.gif",
		"/images/loader/photo-uploading.gif"
	];
	
	for(var i=0;i<urls.length;i++) {
		image.src = urls[i];
	}
	
});
