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
//= require_tree ./autoload
//= require jquery
//= require jquery_ujs
//= require bootstrap/bootstrap-tooltip
//= require jquery-ui
//= require autocomplete-rails
//= require unobtrusive_flash
//= require unobtrusive_flash_ui
//= require admin


UnobtrusiveFlash.flashOptions['timeout'] = 5000; // milliseconds

$(function(){
  $("a[rel='tooltip']").tooltip();
})

$(document).ready(function () {
    var loadingmessage = $('#loading');
    var button = $('#button_loading');

    loadingmessage.hide();

    button.click( function()
           {
             loadingmessage.show();
             button.hide();
           }
    );
    
});