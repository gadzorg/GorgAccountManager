// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require autocomplete-rails
//= require unobtrusive_flash
//= require unobtrusive_flash_ui
//= require_tree ./autoload

UnobtrusiveFlash.flashOptions["timeout"] = 30000; // milliseconds

$(function () {
  $("a[rel='tooltip']").tooltip();
});

$(document).ready(function () {
  var loadingmessage = $("#loading");
  var button = $("#button_loading");

  loadingmessage.hide();

  button.click(function () {
    if (button.parents("form").valid()) {
      loadingmessage.show();
      button.hide();
    }
  });

  $(".datepicker").pickadate({
    selectMonths: true, // Creates a dropdown to control month
    selectYears: 115, // Creates a dropdown of 15 years to control year
    max: Date.now(),
  });
});
