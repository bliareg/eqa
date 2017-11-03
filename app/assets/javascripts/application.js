// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery-ui/sortable
//= require jquery-ui/droppable
//= require jquery-ui/selectmenu
//= require jquery-ui/progressbar
//= require jquery-ui/autocomplete
//= require chosen-jquery
//= require Chart.min
//= require jsDataRender/init.js
//= require colResizable-1.6.min
//= require_tree .

var myDropzone = null;

window.addEventListener("popstate", function(e) {
    document.location.href = location.pathname;
}, false)

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return a.indexOf(i) < 0;});
};

Dropzone.prototype._getParamName = function(n) {
  if (typeof this.options.paramName === "function") {
    return this.options.paramName(n);
  } else if (this.options.paramName1) {
    return this.options.paramName1 + this.options.paramName2;
  } else {
    return "" + this.options.paramName + (this.options.uploadMultiple ? "[" + n + "]" : "");
  }
};

$.ajaxSetup({ cache: false });

document.cookie = 'timezone=' + -(new Date().getTimezoneOffset())/60

function check_iframe(){
  if (!isInIframe()){
    document.cookie = "qa_addon='';expires=Thu, 01 Jan 1970 00:00:01 GMT;path=/";
  }
}

function isInIframe () {
  try {
    return window.self !== window.top;
  } catch (e) {
    return true;
  }
}

function connect_to_atlassian(base_url){
  if (document.cookie.indexOf('qa_addon=') > 0){
    (function() {
      var options = 'sizeToParent:true;'
      var script = document.createElement("script");
      script.src = base_url + '/atlassian-connect/all.js';
      script.setAttribute('data-options', options);
      document.getElementsByTagName("head")[0].appendChild(script);
    })();
  };
}

function clear_page(){
  $('#head_menu').remove();
  $('#projects-left-menu').remove();
  $('.main-footer').remove();
  $('div.main-content-title').remove();
  $('ul.nav-tabs').hide();
  $('.content-with-sidebar').removeClass('content-with-sidebar');
  $('.main-content').css('margin-top','0px');
}


