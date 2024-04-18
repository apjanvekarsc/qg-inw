$(document).ready(function() {

  $('#inw_guideline_form').bind('submit', function() {
      $(this).find(':input').removeAttr('disabled');
  });

});