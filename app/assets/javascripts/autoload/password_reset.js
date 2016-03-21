function checkPass()
{
    //Store the password field objects into variables ...
    var pass1 = $('#user_password');
    var pass2 = $('#user_password_confirmation');
    //Store the Confimation Messages Object ...
    var messageok = $('#confirmMessageOK');
    var messagenok = $('#confirmMessageNOK');
    var messagenokshort = $('#confirmMessageNOKSHORT');

    //Compare the values in the password field
    //and the confirmation field. Dont chef if
    // passwd is blank ou pass2 to short
    if (pass1.val().length != 0 && pass2.val().length != 0) {
        if (pass1.val() == pass2.val()) {
            if (pass1.val().length < 8) {
                messagenokshort.show();
                messageok.hide();
                messagenok.hide();
                // alert("ok...");

            }
            else {
                messageok.show()
                messagenok.hide()
                messagenokshort.hide()
                // alert("ok");

            }
        }
        else {
            messagenok.show()
            messageok.hide()
            messagenokshort.hide()
            // alert("nop");

        }
    }
    disable_or_not_button();
}


$(document).ready(function () {
    var timeout_password;
    var messageok = $('#confirmMessageOK');
    var messagenok = $('#confirmMessageNOK');
    var messagenokshort = $('#confirmMessageNOKSHORT');

    messageok.hide()
    messagenok.hide()
    messagenokshort.hide()

    $('.box').on('change keyup', '#user_password_confirmation', function () {
        clearTimeout(timeout_password);
        timeout_password = setTimeout(function() {
            checkPass();
        }, 500);
        // alert("document ready");
    });
    
});