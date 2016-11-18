// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready(function () {
  var target = $("#addresses");
  var hruid = target.data("hruid");
	$.ajax({
		url: "/module/merge/address/" + hruid,
		cache: false,
		success: function(html){
			target.replaceWith(html);
		}
	});
});