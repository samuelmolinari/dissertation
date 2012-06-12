$(document).ready(function(){
  
  var connection_selected = 0;
  var with_connections_selected = 1;
  
  var connections_list = $("#privacy_advanced_manager_connections_list .user-block input[type=checkbox]");
  var with_connections_list = $("#privacy_advanced_manager_with_connections_list .user-block input[type=checkbox]");
  
  var connections_list_container = $("#privacy_advanced_manager_connections_list");
  var with_connections_list_container = $("#privacy_advanced_manager_with_connections_list");
  var cover_list_container = $("#privacy_advanced_manager_cover_list");
  
  $("#global_auto_hide_group,#global_auto_hide_cover_type").change(function(){
    
    $.ajax({
      url:$(this).parent().attr("action")+".json",
      data:$(this).parent().serializeArray(),
      type:"POST",
      success: function(feedback){
        displayFeedback(feedback["message"]);
      }
    });
    
  });
  
  $("#privacy_advanced_manager_cover_list input[type=submit]").click(function(event){
    
    event.preventDefault();
    var connections_form = $("#privacy_advanced_manager_connections_list form");
    var with_connections_form = $("#privacy_advanced_manager_with_connections_list form");
    var cover_type_form = $("#privacy_advanced_manager_cover_list form");
    var final_form = {};
    var counter = 0;
    
    $("#privacy_advanced_manager_connections_list input[type=checkbox]").each(function(){
      if($(this).attr("checked") != undefined) {
        var id = $(this).attr("id").replace("connection_user_id_","");
        final_form["connections["+counter+"]"] = id;
        counter++;
      }
    });
    
    counter = 0;
    
    $("#privacy_advanced_manager_with_connections_list input[type=checkbox]").each(function(){
      if($(this).attr("checked") != undefined) {
        var id = $(this).attr("id").replace("with_connection_user_id_","");
        final_form["with_connections["+counter+"]"] = id;
        counter++;
      }
    });
    
    $("#privacy_advanced_manager_cover_list input[type=radio]").each(function(){
      if($(this).attr("checked") != undefined) {
        var id = $(this).attr("id").replace("cover_type_","");
        final_form["cover_type"] = id;
      }
    });
    
    $.ajax({
			url:$(this).parent().attr("action")+".json",
			type:"POST",
			headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
      data: final_form,
			success: function(feedback){
				displayFeedback(feedback["message"]);
			}
		});
    
  });
  
  connections_list.change(function(){
    
    var is_checked = $(this).attr("checked") != undefined;
    
    if(is_checked) {
      
      connection_selected++;
      
    } else {
      
      connection_selected--;
      
    }
    
    if(connection_selected > 0) {
      
      with_connections_list_container.stop().fadeIn(200,function(){
        if(with_connections_selected > 0) {
          cover_list_container.stop().fadeIn(200);
        }
      });
      
      
    } else {

      cover_list_container.stop().fadeOut(200,function(){
        with_connections_list_container.stop().fadeOut(200);
      });
      
    }
  
  });
  
  with_connections_list.change(function(){
    
    var is_checked = $(this).attr("checked") != undefined;
    var is_default = $(this).attr("id") == "with_connection_user_id_0"
    
    if(is_checked) {
      
      if(!is_default) {
        
        if($("#with_connection_user_id_0").attr("checked") != undefined) {
          
          $("#with_connection_user_id_0").attr("checked",false);
          with_connections_selected--;
          
        }
      
      }
      
      with_connections_selected++;
      
    } else {
      
      with_connections_selected--;
      
    }
    
    if(with_connections_selected > 0) {
      
      cover_list_container.stop().fadeIn(200);

    } else {

      cover_list_container.stop().fadeOut(200);
      
    }
    
  });
  
  $("#with_connection_user_id_0").change(function(){
    
    var is_checked = $(this).attr("checked") != undefined;
    
    if(is_checked) {
      
      with_connections_list.attr("checked",false);
      
      $(this).attr("checked","checked");
      
      with_connections_selected = 1;
      
    }
    
  });
  
});