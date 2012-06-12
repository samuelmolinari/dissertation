$(document).ready(function(){
	
	$(".autocomplete_field").keydown(function(e){
		var code = (e.keyCode ? e.keyCode : e.which);
		if(code == 40 || code ==38) {
			e.preventDefault();
		}
	});
	
	$(".autocomplete_field").keypress(function(e){
		var code = (e.keyCode ? e.keyCode : e.which);
		if(code == 40 || code ==38) {
			e.preventDefault();
		}
	});
	
	$(".autocomplete_field").keyup(function(e){
		
		var code = (e.keyCode ? e.keyCode : e.which);
		var fieldId_id = $(this).attr("id").replace("_name","_user_id");
		
		// UP
		if(code == 40) {
			e.preventDefault();
			var next = $("#selected-name").next();
			
			if(next != null && next != undefined && next.length > 0) {
				$("#selected-name").attr("id","");
				next.attr("id","selected-name");
			}
			$("#"+fieldId_id).val($("#selected-name").attr("data-user_id"));
		} else if(code ==38) {
			e.preventDefault();
			var previous = $("#selected-name").prev();
			if(previous != null && previous != undefined && previous.length > 0) {
				$("#selected-name").attr("id","");
				previous.attr("id","selected-name");
			}
			$("#"+fieldId_id).val($("#selected-name").attr("data-user_id"));
		} else {
			var str = $(this).val();
			var obj = $(this);
			
			if(str.length > 0) {
				$.ajax({
					url:"/manage/autocomplete_user",
					type:"GET",
					headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')},
					data:{name:str},
					success: function(list){
						list = JSON.parse(list);
						$("#autocomplete-container").show();
						$("#autocomplete-container").html("");
						
						$("#autocomplete-container").offset({top:obj.offset().top+obj.height()+10,left:obj.offset().left});
						$("#autocomplete-container").width(obj.width());
						
						for(var i=0;i<list.length;i++) {
							var user = list[i];
							$("#autocomplete-container").append('<div data-user_id='+user["id"]+'>'+user["fname"]+' '+user["lname"]+'</div>')
						}
						
						if(list.length > 0) {
							$("#autocomplete-container").children().first().attr("id","selected-name");
							$("#"+fieldId_id).val(list[0]["id"]);
						}
					}
				});
			} else {
				$("#autocomplete-container").hide();
			}
		}
	});
	
	$(".submit-btn a").click(function(e){
		e.preventDefault();
		$(this).parents("form").submit();
	})
	
})
