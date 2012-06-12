function PageTransition(fn,containerID,url,data,rewind) {
	
	if(rewind == null || rewind == undefined) rewind = false;
	if(data == null || data == undefined) data = {};
	
	var container = $("#"+containerID);
	var currentBlock = container.children().first();
	
	container.css({
		position:"relative",
		height:container.height(),
		width:container.width(),
		overflow:"hidden"
	});
	
	currentBlock.css({
		position:"absolute",
		top:0,
		left:0
	});
	
	this.start = function() {
		$.ajax({
			url:url,
			data:data,
			headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')},
			type: "POST",
			success: function(html){

				container.append(html);
				var newBlock = container.children().last();
				
				newBlock.css({
					position:"absolute",
					width:container.width(),
					top:0
				});
				
				if(!rewind) {
					newBlock.css("left",-container.width());
					currentBlock.animate({left:container.width()},100);
				} else {
					newBlock.css("left",container.width());
					currentBlock.animate({left:-container.width()},100);
				}
				
				newBlock.animate({left:0},100,function(){
					currentBlock.remove();
					newBlock.css({
						position:"relative"
					});
					container.animate({height:"auto"});
					fn();
				});
				
			}
		});
	}
	
}
