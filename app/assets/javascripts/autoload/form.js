$(document).ready(function() {
	fixForms();
	var elements = document.querySelectorAll('input,select,textarea');

	for (var i = elements.length; i--;) {
		elements[i].addEventListener('invalid', function () {
			this.scrollIntoView(false);
		});
	}
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


