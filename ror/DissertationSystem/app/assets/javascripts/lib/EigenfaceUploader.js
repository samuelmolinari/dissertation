function EigenfaceUploader(dropAreaID,dropFieldID,dropAreaStatusID,listID) {
	
	var busy = false;
	var supportedMimeType = {
		image : {
			jpeg 	: true,
			jpg		: true,
			jpe		: true,
			png		: true,
			gif		: true,
			tiff	: true,
			tif		: true,
			svg		: true
		}
	}
	
	window.addEventListener("load",function(){
		
		var droparea = document.getElementById(dropAreaID);
		var dropfield = document.getElementById(dropFieldID);
		var dropareaStatus = document.getElementById(dropAreaStatusID);
		var list = document.getElementById(listID);
		
		dropfield.addEventListener("dragenter",function(event){
			event.preventDefault();
			event.stopPropagation();
			
			dropareaStatus.innerHTML = "Drop!";
			droparea.style.borderColor = "#0097ff";
			
			return false;
		},false);
		
		dropfield.addEventListener("dragover",function(event){
			event.preventDefault();
			event.stopPropagation();
			return false;
		},false);
		
		dropfield.addEventListener("drop",function(event){
			event.preventDefault();
			event.stopPropagation();
			
			dropareaStatus.innerHTML = "Drag &amp; Drop a Photo of You Here";
			droparea.style.borderColor = "#dfdfdf";
			
			var files = event.dataTransfer.files;
			
			if(files && files.length > 0) {
				busy = true;
				var file;
								
				for(var i=0;i<files.length;i++) {
					if(hasValidMimeType(files[i])) {
						file = files[i];
						break;
					}
				}
				
				var formdata = new FormData();
				formdata.append("photo", file);
				
				if (formdata) {
					$(droparea).fadeOut(500,function(){
						$(list).append('<a class="cancel-btn" href="'+window.location+'" alt="cancel">Cancel</a>');
					});
					$.ajax({  
				        url: "/face/pre_training_upload.json",  
				        type: "POST",  
				        data: formdata,  
				        processData: false,  
				        contentType: false,
				        headers: {
							'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
					  	},
				        success: function (json) {
				            for(var i=0;i<json["faces"].length;i++){
				            	$(list).append('<a href="/face/train?ref='+json["ref"]+'&face='+i+'"><img src="'+json["faces"][i]+'" alt="face '+i+'" /></a>')
				            }
				            
				            if(json.length < 1) {
				            	$(droparea).fadeIn(500);
				            }
				            
				        }  
				    });
				}
				
			}
			
			return false;
			
		},false);
		
		dropfield.addEventListener("dragleave",function(event){
			event.preventDefault();
			event.stopPropagation();
			
			dropareaStatus.innerHTML = "Drag &amp; Drop a Photo of You Here";
			droparea.style.borderColor = "#dfdfdf";
			
			return false;
		},false);
		
	});
	
	function hasValidMimeType(file) {
		var fileType = file.type;
		var mimeType;
		var type;
		var subtype;
		
		for(type in supportedMimeType) {
			for(subtype in supportedMimeType[type]) {
				mimeType = type+"/"+subtype;
				if(fileType == mimeType) {
					return true;
				}
			}
		}
		
		return false;
	}

}
