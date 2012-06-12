function Album(id) {
	window.addEventListener("load",function(){
		
		var albums = document.getElementsByClassName("photo-album");

		for(var i=0;i<albums.length;i++) {
			
			albums[i].addEventListener("mousewheel",function(e){
				
				var album = this;
				var jalbum = $(album);
				var photos = album.getElementsByClassName("photo");
				
				e.preventDefault();

				if(e.wheelDelta > 0) {
					$(photos[photos.length-1]).fadeOut(50,function(){
						$(photos[photos.length-1]).remove();
						jalbum.prepend('<div class="photo" style="opacity:0; background-image:url(\'/images/loader/photo-rendering.gif\');width:80px;height:53px;background-color:#0097ff;"></div>');
						photos = album.getElementsByClassName("photo");
						
						$.ajax({
							data:{album_id:jalbum.attr("data-id"),photo_ref:$(photos[1]).attr("data-ref"), size:"tiny"},
							url: "/album/next_photo.json",
							type: "POST",
							headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
							success: function(p) {
								$(photos[0]).attr("data-ref",p.ref)
								$(photos[0]).attr("style",p.css)
							}
						});
						
						$(photos[photos.length-3]).animate({opacity:1},"100");
						$(photos[photos.length-2]).animate({opacity:0.5},"100");
						$(photos[photos.length-1]).animate({opacity:0.3},"100");
					});
				} else if(e.wheelDelta < 0) {
					$(photos[0]).fadeOut(50,function(){
						$(photos[0]).remove();
						jalbum.append('<div class="photo" style="opacity:0; background-image:url(\'/images/loader/photo-rendering.gif\');width:80px;height:53px;background-color:#0097ff;"></div>');
						photos = album.getElementsByClassName("photo");
						
						$.ajax({
							data:{album_id:jalbum.attr("data-id"),photo_ref:$(photos[1]).attr("data-ref"), size:"tiny"},
							url: "/album/prev_photo.json",
							type: "POST",
							headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
							success: function(p) {
								$(photos[photos.length-1]).attr("data-ref",p.ref)
								$(photos[photos.length-1]).attr("style",p.css)
							}
						});
						$(photos[photos.length-3]).animate({opacity:1},"100");
						$(photos[photos.length-2]).animate({opacity:0.5},"100");
						$(photos[photos.length-1]).animate({opacity:0.3},"100");
					});
				}
				
			},false);
		}
		
	},false);
}