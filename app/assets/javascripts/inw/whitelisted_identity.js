$(document).ready(function(){
    
    $('#full_attachments').hide();
    
    $("#view_attachments").live('click',function(){
      $('#attachment').hide();
      $('#full_attachments').show();
    });

    $("#hide_attachments").live('click',function(){
      $('#attachment').show();
      $('#full_attachments').hide();
    });
});