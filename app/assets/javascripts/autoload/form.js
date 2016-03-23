$(document).ready(function() {
     fixForms();
});
$(document).bind('DOMNodeInserted',function(){
	fixForms();
});

function fixForms(){
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
}