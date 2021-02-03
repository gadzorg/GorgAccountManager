function checkPassRules(selector) {
  var pass = $(selector).val();

  var ok = true;
  ok = toggle_icon_for("password-rule-length", checkPassLength(pass)) && ok;
  ok = toggle_icon_for("password-rule-spaces", checkPassSpaces(pass)) && ok;
  ok =
    toggle_icon_for("password-rule-characters", checkPassCharacters(pass)) &&
    ok;

  toggle_submit_button(ok);
  return ok;
}

function toggle_submit_button(enabled) {
  var button = $("#change-password-button");
  button.prop("disabled", !enabled).toggleClass("disabled", !enabled);
  button.parent().toggleClass("disabled", !enabled);
}

function toggle_icon_for(rule_id, is_ok) {
  var target = $("#" + rule_id + " .icon-cell i");
  if (is_ok) {
    target.text("check");
    target.removeClass("red-text");
    target.addClass("green-text");
  } else {
    target.text("clear");
    target.removeClass("green-text");
    target.addClass("red-text");
  }
  return is_ok;
}

function checkPassLength(pass) {
  return pass.length >= 8;
}

function checkPassSpaces(pass) {
  return pass[0] != " " && pass[pass.length - 1] != " ";
}

function checkPassCharacters(pass) {
  return /^[a-zA-Z0-9!\"#$%&'‘()*+,\-.\/:;<=>?@\[\\\]^{|}~\s]+$/.test(pass);
}

function checkPass() {
  //Store the password field objects into variables ...
  var pass1 = $("#user_password");
  var pass2 = $("#user_password_confirmation");
  //Store the Confimation Messages Object ...
  var messageok = $("#confirmMessageOK");
  var messagenok = $("#confirmMessageNOK");
  var messagenokshort = $("#confirmMessageNOKSHORT");

  //Compare the values in the password field
  //and the confirmation field. Dont chef if
  // passwd is blank ou pass2 to short
  if (pass1.val().length != 0 && pass2.val().length != 0) {
    if (pass1.val() == pass2.val()) {
      messageok.show();
      messagenok.hide();
      messagenokshort.hide();
      // alert("ok");
      return true;
    } else {
      messagenok.show();
      messageok.hide();
      messagenokshort.hide();
      // alert("nop");

      return false;
    }
  }
}

$(document).ready(function () {
  var timeout_password;
  var messageok = $("#confirmMessageOK");
  var messagenok = $("#confirmMessageNOK");
  var messagenokshort = $("#confirmMessageNOKSHORT");

  messageok.hide();
  messagenok.hide();
  messagenokshort.hide();

  var userPasswordSelector = "#user_password";
  if (document.querySelector(userPasswordSelector)) {
    checkPassRules(userPasswordSelector);
  }

  $("#password-card").on("change keyup", "#user_password", function () {
    checkPassRules(userPasswordSelector);
  });

  $("#password-card").on(
    "change keyup",
    "#user_password_confirmation",
    function () {
      clearTimeout(timeout_password);
      timeout_password = setTimeout(function () {
        checkPass();
      }, 500);
      // alert("document ready");
    }
  );
});
