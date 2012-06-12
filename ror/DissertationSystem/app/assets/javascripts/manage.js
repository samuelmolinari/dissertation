//= require lib/PhotoUploader
//= require lib/Album

$(document).ready(function() {
	var photoUploader = new PhotoUploader("drop-area","drop-field","drop-area-status","upload-status","photo-upload-counter");
	new Album("");
});

