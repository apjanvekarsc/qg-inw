$(document).ready(function(){
  $('#partner_validate_vpa').prop("disabled",true);
  if($('#partner_allow_upi').is(":checked"))
  {
    $('#partner_validate_vpa').prop("disabled",false);
    $('#partner_merchant_id').prop("disabled",false);

  }
  $('#partner_sender_rc').prop('readOnly',true);
  if(!$('#partner_allow_imps').is(":checked")){
    $('#partner_mmid').prop('disabled',true);
    $('#partner_mobile_no').prop('disabled',true);
  }
  if ($('#partner_service_name').val() == 'RPL'){
      $('#partner_sender_rc').prop('readOnly',false);
    }
    
  if(!$('#partner_allow_imps').is(":checked")){
    $('#partner_mmid').prop('disabled',true);
    $('#partner_mobile_no').prop('disabled',true);
  }

 $("#partner_allow_upi").on("click", function () {
  if($('#partner_allow_upi').is(":checked"))
  {
    $('#partner_merchant_id').prop('disabled',false);
    $('#partner_validate_vpa').prop("disabled",false);
   }
   else
   {
    $('#partner_merchant_id').prop('disabled',true);
    $('#partner_validate_vpa').prop("disabled",true);
    $('#partner_merchant_id').val('');
    $('#partner_validate_vpa').prop("checked",false);
   }
 });

  $("#partner_notify_on_status_change").on("click", function () {
    if(!$('#partner_notify_on_status_change').is(":checked")){
      $('#partner_app_code').val('');
      $('#partner_app_code').prop('readOnly',true);
    }
    else{
      $('#partner_app_code').prop('readOnly',false);     
    }
  });
  
  if(!$('#partner_will_whitelist').is(":checked") ) {
    $('#partner_hold_for_whitelisting').prop("checked",false);
    $('#partner_hold_for_whitelisting').prop('disabled',true);
    $('#partner_txn_hold_period_days').val(0);
    $('#partner_txn_hold_period_days').prop('readOnly',true);
    $('#partner_will_send_id').prop("checked",false);
    $('#partner_will_send_id').prop('disabled',true);
  }
  else {
    if ($('#partner_service_name').val() != 'INW2') {
      $('#partner_will_send_id').prop('disabled',false);
    }
    else {
      $('#partner_hold_for_whitelisting').prop('disabled',false);
      $('#partner_txn_hold_period_days').prop('readOnly',false);
      $('#partner_will_send_id').prop('disabled',false);
    }
  }

  $("#partner_will_whitelist").on("click", function () {
    if(!$('#partner_will_whitelist').is(":checked") ) {
      $('#partner_hold_for_whitelisting').prop("checked",false);
      $('#partner_hold_for_whitelisting').prop('disabled',true);
      $('#partner_txn_hold_period_days').val(0);
      $('#partner_txn_hold_period_days').prop('readOnly',true);
      $('#partner_will_send_id').prop("checked",false);
      $('#partner_will_send_id').prop('disabled',true);
    }
    else {
      if ($('#partner_service_name').val() != 'INW2') {
        $('#partner_will_send_id').prop('disabled',false);
      }
      else {
        $('#partner_hold_for_whitelisting').prop('disabled',false);
        $('#partner_txn_hold_period_days').prop('readOnly',false);
        $('#partner_will_send_id').prop('disabled',false);
      }
    }
  });
  
  if ($('#partner_service_name').val() == 'INW2'){
    if ($('#partner_will_whitelist').is(":checked")) {
      $('#partner_hold_for_whitelisting').prop('disabled',false);
      $('#partner_txn_hold_period_days').prop('readOnly',false);
      $('#partner_will_send_id').prop('disabled',false);
    }
    else {
      $('#partner_hold_for_whitelisting').prop("checked",false);
      $('#partner_txn_hold_period_days').val(0);
      $('#partner_will_send_id').prop("checked",false);
      $('#partner_hold_for_whitelisting').prop('disabled',true);
      $('#partner_txn_hold_period_days').prop('readOnly',true);
      $('#partner_will_send_id').prop('disabled',true);
    }
    //$('#partner_remitter_sms_allowed').prop("checked",false);
    //$('#partner_remitter_sms_allowed').prop('disabled',true);
    //$('#partner_remitter_email_allowed').prop("checked",false);
    //$('#partner_remitter_email_allowed').prop('disabled',true);
    $('#partner_auto_reschdl_to_next_wrk_day').prop('disabled',false);
  }
  else {
    if ($('#partner_will_whitelist').is(":checked")) {
      $('#partner_will_send_id').prop('disabled',false);
    }
    else {
      $('#partner_will_send_id').prop("checked",false);
      $('#partner_will_send_id').prop('disabled',true);
    }
    $('#partner_hold_for_whitelisting').prop("checked",false);
    $('#partner_txn_hold_period_days').val(0);
    $('#partner_hold_for_whitelisting').prop('disabled',true);
    $('#partner_txn_hold_period_days').prop('readOnly',true);
    //$('#partner_remitter_sms_allowed').prop('disabled',false);
    //$('#partner_remitter_email_allowed').prop('disabled',false);
    $('#partner_auto_reschdl_to_next_wrk_day').prop('checked',false);
    $('#partner_auto_reschdl_to_next_wrk_day').prop('disabled',true);
  }
  
  $("#partner_service_name").on("change", function () {
    $('#partner_sender_rc').prop('readOnly',true);
    if ($('#partner_service_name').val() == 'RPL'){
      $('#partner_sender_rc').prop('readOnly',false);
    }
    if ($('#partner_service_name').val() == 'INW2'){
      if ($('#partner_will_whitelist').is(":checked")) {
        $('#partner_hold_for_whitelisting').prop('disabled',false);
        $('#partner_txn_hold_period_days').prop('readOnly',false);
        $('#partner_will_send_id').prop('disabled',false);
      }
      else {
        $('#partner_hold_for_whitelisting').prop("checked",false);
        $('#partner_txn_hold_period_days').val(0);
        $('#partner_will_send_id').prop("checked",false);
        $('#partner_hold_for_whitelisting').prop('disabled',true);
        $('#partner_txn_hold_period_days').prop('readOnly',true);
        $('#partner_will_send_id').prop('disabled',true);
      }
      //$('#partner_remitter_sms_allowed').prop("checked",false);
      //$('#partner_remitter_sms_allowed').prop('disabled',true);
      //$('#partner_remitter_email_allowed').prop("checked",false);
      $//('#partner_remitter_email_allowed').prop('disabled',true);
      $('#partner_auto_reschdl_to_next_wrk_day').prop('disabled',false);
    }
    else {
      if ($('#partner_will_whitelist').is(":checked")) {
        $('#partner_will_send_id').prop('disabled',false);
      }
      else {
        $('#partner_will_send_id').prop("checked",false);
        $('#partner_will_send_id').prop('disabled',true);
      }
      $('#partner_hold_for_whitelisting').prop("checked",false);
      $('#partner_txn_hold_period_days').val(0);
      $('#partner_hold_for_whitelisting').prop('disabled',true);
      $('#partner_txn_hold_period_days').prop('readOnly',true);
      //$('#partner_remitter_sms_allowed').prop('disabled',false);
      //$('#partner_remitter_email_allowed').prop('disabled',false);
      $('#partner_auto_reschdl_to_next_wrk_day').prop('checked',false);
      $('#partner_auto_reschdl_to_next_wrk_day').prop('disabled',true);
    }

    if($('#partner_service_name').val() == 'RPL'){
      $('#partner_connector_account').prop('disabled',false);  
    }
    else
    {
      $('#partner_connector_account').prop('disabled',true);
    }  

    if ($('#partner_service_name').val() == 'ANTFN'){
      $('#partner_sender_mid').prop('disabled',false);
      $('#partner_liquity_provider_id').prop('disabled',false);
      $('#partner_anchorid').prop('disabled',false);
      $('#partner_receiver_mid').prop('disabled',false);
    }
    else{
      $('#partner_sender_mid').prop('disabled',true);
      $('#partner_liquity_provider_id').prop('disabled',true);
      $('#partner_anchorid').prop('disabled',true);
      $('#partner_receiver_mid').prop('disabled',true);
    }
  });
  
  $("#partner_hold_for_whitelisting").on("change", function () {
    if ($('#partner_hold_for_whitelisting').is(":checked")){
      $('#partner_txn_hold_period_days').prop('readOnly',false);
    }
    else {
      $('#partner_txn_hold_period_days').val(0);
      $('#partner_txn_hold_period_days').prop('readOnly',true);
    }
  });

  if ($('#partner_hold_for_whitelisting').is(":checked")){
    $('#partner_txn_hold_period_days').prop('readOnly',false);
  }
  else {
    $('#partner_txn_hold_period_days').val(0);
    $('#partner_txn_hold_period_days').prop('readOnly',true);
  }
  if ($("#partner_neft_limit_check").is(':checked')){
        $("#partner_working_day_limit").prop("disabled", false);
        $("#partner_non_working_day_limit").prop("disabled", false);
        $("#partner_action_limit_breach").prop("disabled", false);

      } 
    else{
        $("#partner_working_day_limit").attr("value", "");
        $("#partner_non_working_day_limit").attr("value", "");
        $("#partner_action_limit_breach").attr("value", "");

        $("#partner_working_day_limit").prop("disabled", true);
        $("#partner_non_working_day_limit").prop("disabled", true);
        $("#partner_action_limit_breach").prop("disabled", true);

      }

    $("#partner_neft_limit_check").click(function () {
      if ($("#partner_neft_limit_check").is(':checked')){
        $("#partner_working_day_limit").prop("disabled", false);
        $("#partner_non_working_day_limit").prop("disabled", false);
        $("#partner_action_limit_breach").prop("disabled", false);

      } 
      else{
        $("#partner_working_day_limit").val('');
        $("#partner_non_working_day_limit").val('');
        $("#partner_action_limit_breach").val('');

        $("#partner_working_day_limit").prop("disabled", true);
        $("#partner_non_working_day_limit").prop("disabled", true);
        $("#partner_action_limit_breach").prop("disabled", true);

      }
    });
});