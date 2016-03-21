$(document).ready(function() {
	// hach to swap label and input order
	// $('input').each(function() {
 //  		$(this).insertBefore( $(this).prev('label') );
	// });
/*	$('input').each(function() {
		var a = $(this).parent()
  		if($(a[0]).attr('class') != "group") {
			alert("fff")
		}
  		
	});*/

	// dirty hack for autofocus fields, I hate JS.
    $('input[autofocus]').addClass( 'notempty');
	// check if inputs are empty
	$('input, textarea').each(function () {
		if($(this).val() != '') {
			$(this).addClass( 'notempty')
		}
	});

	$('input, textarea').focus(function () {
		$(this).addClass( 'notempty');
			console.log($(this));

	});

	$('input, textarea').focusout(function () {
		if($(this).val() == '') {
			$(this).removeClass('notempty');
		}
		
	});

	
});