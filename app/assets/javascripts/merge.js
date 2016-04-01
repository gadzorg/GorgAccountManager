// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function () {
	$.ajax({
		url: "/module/merge/address/" + $("#hruid").children().first().attr("name"),
		cache: false,
		success: function(html){
			$("#addresses").replaceWith(html);
			
		}
	});
});