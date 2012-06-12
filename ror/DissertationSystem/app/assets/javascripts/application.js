// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require_self
//= require image-preloader
//= require lib/PageTransition
//= require lib/Queue

 function displayFeedback(message) {
    $("#feedback-block").html(message);
    $("#feedback-container").fadeIn(500).delay(2000).fadeOut(500);
  }

$(document).ready(function() {
  
  $("#feedback-container.has_feedback").delay(2000).fadeOut(500);
	
	$("a.transitional-btn").live("click",function(evt){
		evt.preventDefault();
		var rewind = location.href;
		
		if($(this).attr("data-rewind-path")) {
			rewind = $(this).attr("data-rewind-path");
		}
		
		new PageTransition(
			function(){},
			$(this).attr("data-transition-container-id"),
			$(this).attr("href"),
			{
				transition_rewind:rewind,
				transition_container_id:$(this).attr("data-transition-container-id")
			},
			$(this).attr("data-original-content") == "true"
		).start();
	});
	
	$("form.transitional-form").live("submit",function(evt){
		evt.preventDefault();
		
		var rewind = location.href;
		var form = $(this);
		
		if(form.attr("data-rewind-path")) {
			rewind = form.attr("data-rewind-path");
		}
		
		data = form.serializeArray()
		
		$.ajax({
			url:form.attr("action"),
			type:"POST",
			headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')},
			data:data,
			success: function(callback){
				if(callback) {
					new PageTransition(
						function(){},
						form.attr("data-transition-container-id"),
						form.attr("data-href"),
						{
							transition_rewind:rewind,
							transition_container_id:form.attr("data-transition-container-id")
						},
						form.attr("data-original-content") == "true"
					).start();
				}
			}
		});
		
	});
	

	/**
	 * Check for recognised faces of the currrent user
	 */
	setInterval(function(){
	 $.ajax({
	 url:"/notification_centre/recognition",
	 type:"POST",
	 headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')},
	 success: function(count){
	 if(count > 0) {
	 $("#recognition-notifier").fadeIn("500");
	 $("#recognition-notifier-counter-value").html(count);
	 } else {
	 $("#recognition-notifier").fadeOut("500");
	 }
	 }
	 });
	},5000); 
	
	
});
