function PhotoUploader(dropAreaID,dropFieldID,dropAreaStatusID,listID,counterClassName) {
	
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
	
	var maxAsyncUpload = 3;
	var uploadsInProgress = 0;
	var displayUploadStatus = true;
	var displayRenderStatus = true;
	var counter = 0;
	var listElementNextAvailableID = 1;
	var listElementPatternID = "image-in-progress-";
	var busy = false;
	var uploadQueue = new Queue();
	
	this.isBusy = function(){
		return busy;
	}
	
	this.getDisplayUploadStatus = function(){
		return displayUploadStatus;
	}
	
	this.getDisplayRenderStatus = function(){
		return displayRenderStatus;
	}
	
	this.setDisplayUploadStatus = function(val){
		displayUploadStatus = val;
	}
	
	this.setDisplayRenderStatus = function(val){
		displayRenderStatus = val;
	}
	
	window.addEventListener("load",function(){
		
		var droparea = document.getElementById(dropAreaID);
		var dropfield = document.getElementById(dropFieldID);
		var dropareaStatus = document.getElementById(dropAreaStatusID);
		var list = document.getElementById(listID);
		var totalPhotosCount = parseInt(document.getElementById("total-photos-count").innerText);
			
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
			
			dropareaStatus.innerHTML = "Drag &amp; Drop your files here";
			droparea.style.borderColor = "#dfdfdf";
			
			var files = event.dataTransfer.files;
			
			if(files && files.length > 0) {
				busy = true;
								
				for(var i=0;i<files.length;i++) {
					if(hasValidMimeType(files[i])) {
						var id = generateListElementID();
						loadImage(files[i],id);
						uploadQueue.offer([files[i],id]);
					}
				}
				
				startUploads();
				
				if(uploadQueue.peek() != null) {
					var t = setInterval(function(){
						startUploads();
						if(uploadQueue.peek() == null) {
							window.clearInterval(t);
						}
					},500);
				}
				
			}
			
			return false;
			
		},false);
		
		dropfield.addEventListener("dragleave",function(event){
			event.preventDefault();
			event.stopPropagation();
			
			dropareaStatus.innerHTML = "Drag &amp; Drop your files here";
			droparea.style.borderColor = "#dfdfdf";
			
			return false;
		},false);
		
		function uploadImage(file,id) {
			if(displayUploadStatus)
				renderImage(file,id);
				
			var formdata = new FormData();
			
			formdata.append("imageuploader", file);
			formdata.append("album_id", $("#select-album").val())
			if (formdata) {
				uploadsInProgress++;
			    $.ajax({  
			        url: "/photo/upload.json",  
			        type: "POST",  
			        data: formdata,  
			        processData: false,  
			        contentType: false,
			        xhr: function() {
			        	var xhr = new window.XMLHttpRequest();
			        	xhr.upload.addEventListener("progress",function(progress){
			        		if (progress.lengthComputable && displayUploadStatus) {
						        var percentComplete = progress.loaded / progress.total;
						        document.getElementById('progress-'+id).innerText = parseInt(percentComplete*100)+"%";
						        document.getElementById('progress-'+id).style.width = parseInt(percentComplete*100)+"%";
							}
			        	},false);
			        	
			        	return xhr;
			        },
			        headers: {
						'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
				  	},
			        success: function (json) {  
			            $("#"+id).remove();
			            totalPhotosCount++;
                  
                  console.log(json.ref)
			            
			            var blockCheck = false;
			            
			            if(displayRenderStatus) {
				            if($("#ognanizer-photos-list div").length >= 20)
				            	$("#ognanizer-photos-list div").last().remove();
				            	
				            $("#ognanizer-photos-list").prepend('<a class="photo" id="pending-photo-'+id+'" style="background-image:url(\'/images/loader/photo-rendering.gif\');width:80px;height:53px;background-color:#0097ff;"></a>');
			            
			            	var checkReady = setInterval(function(){
				            	if(!blockCheck) {
				            		blockCheck = true;
					            	$.ajax({  
								        url: "/photo/is_ready.json",  
								        type: "POST",  
								        data: {ref: json.ref, size:"tiny"},
								        headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
								        success: function (exists) {  
								            if(exists) {
								            	image = new Image();
								            	image.src = "/image_administrator?ref="+json.ref+"&size=tiny"
								            	image.onload = function () {
								            		$("#pending-photo-"+id).attr("style",json.css);
								            		$("#pending-photo-"+id).attr("href","/user/photo?ref="+json.ref+"&uname=");
								            	}
								            	window.clearInterval(checkReady);
								            } else {
								            	blockCheck = false;
								            }
								        }
								    });
							    }
				            },2000)
				            
				            document.getElementById("total-photos-count").innerText = totalPhotosCount;
			            }

			            uploadsInProgress--;
			            counter--;
			            updateHTMLCounters();
			            
			            if(counter <= 0) {
			            	photoManagerButtonStatus(false);
			            	busy = false;
			            }
			        }  
			    });
			    
			}  
		}
		
		function startUploads() {
			var allowedUpload = maxAsyncUpload-uploadsInProgress;
			for(var r=0;r<allowedUpload;r++) {
				if(uploadQueue.peek() == null) break;
				var elem = uploadQueue.poll();
				uploadImage(elem[0],elem[1]);
			}
		}
		
		function loadImage(file,id) {
			counter++;
			updateHTMLCounters();
			photoManagerButtonStatus(true);
			list.innerHTML = list.innerHTML+generateListElementHTML(file,id);
		}
		
		function renderImage(file,id) {
			var reader;
			reader = new FileReader();
		    reader.onload = (function(currentFile) {
		    	return function(e) {
		    		
		    		var img = new Image();
		    		var src = e.target.result;
	    			img.onload = function() {
	    				var width = 0;
	    				var height = 0;
	    				var ratio = 100/img.width;
	    				
	    				width = img.width*ratio;
	    				height = img.height*ratio;
	    				
	    				var canvas = document.getElementById("canvas-"+id);
	    				canvas.getContext('2d').drawImage(img,0,0,width,height);
	    				var dataURL = document.getElementById("canvas-"+id).toDataURL("image/png");
	    				canvas.parentNode.innerHTML = '<img src="'+dataURL+'" alt="'+file.name+'" />'
	    			}
	    			img.src = src;
		    }})(file);  
		    reader.readAsDataURL(file); 
		}
		
		function updateHTMLCounters() {
			var htmlCounters = document.getElementsByClassName(counterClassName);
			for(var c=0;c<htmlCounters.length;c++) {
				htmlCounters[c].innerHTML = counter;
			}
		}
		
		function photoManagerButtonStatus(on) {
			var show = document.getElementById("photo-manager-button").getElementsByClassName("onupload");
			for(var s=0;s<show.length;s++) {
				if(on)
					show[s].style.display = "inline";
				else
					show[s].style.display = "none";
			}
		}
		
	},false);

	
	function generateListElementHTML(file,id) {
		var html = "";
		
		html += '<div class="upload-in-progress" id="'+id+'">';
		html += 	'<div class="thumbnail"><canvas width="100" height="70" id="canvas-'+id+'"></canvas></div>';
		html += 	'<div class="detail-block">';
		html += 		'<div class="details">';
		html += 			'<div>Name: <span class="name">'+file.name+'</span></div>';
		html += 			'<div>Size: <span class="size">'+file.size+' bytes</span></div>';
		html += 		'</div>';
		html += 		'<div class="progress-bar">';
		html += 			'<div class="progress" id="progress-'+id+'">0%</div>';
		html += 		'</div>';
		html += 	'</div>';
		html += '</div>';
		
		return html;
	}
	
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
	
	function generateListElementID() {
		var id = listElementPatternID+listElementNextAvailableID;
		listElementNextAvailableID++;
		return id;
	}

}