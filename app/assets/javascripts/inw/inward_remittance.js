$(document).ready(function(){ 
  $("a.verify-link").on("click", function () {
    $(".id_type").text("Verify Identity : " + $(this).data('id-type') + " " + $(this).data('id-number'));
    $("#whitelisted_identity_partner_id").val($(this).data('partner-id'));
    $("#whitelisted_identity_full_name").val($(this).data('full-name'));
    $("#whitelisted_identity_first_name").val($(this).data('first-name'));
    $("#whitelisted_identity_last_name").val($(this).data('last-name'));
    $("#whitelisted_identity_id_type").val($(this).data('id-type'));
    $("#whitelisted_identity_id_number").val($(this).data('id-number'));
    $("#whitelisted_identity_id_country").val($(this).data('id-country'));
    $("#whitelisted_identity_id_expiry_date").val($(this).data('id-expiry-date'));
    $("#whitelisted_identity_id_issue_date").val($(this).data('id-issue-date'));
    $("#whitelisted_identity_first_used_with_txn_id").val($(this).data('inward-remittance-id'));
    $("#whitelisted_identity_last_used_with_txn_id").val($(this).data('inward-remittance-id'));
    $("#whitelisted_identity_bene_account_no").val($(this).data('bene-account-no'));
    $("#whitelisted_identity_bene_account_ifsc").val($(this).data('bene-account-ifsc'));
    $("#whitelisted_identity_rmtr_code").val($(this).data('rmtr-code'));
    $("#whitelisted_identity_created_for_identity_id").val($(this).data('created-for-identity-id'));
    $("#whitelisted_identity_created_for_txn_id").val($(this).data('created-for-txn-id'));
    $('#verifyIdentity').modal();
  });
  
  $("a.add-link").on("click", function () {
    var $addIdentityForm = $("#addIdentity");
    var data = $(this).data();
    $addIdentityForm.find("#whitelisted_identity_id_type").val(data["idType"]);
    $addIdentityForm.find("#whitelisted_identity_id_number").val(data["idNumber"]);
    $addIdentityForm.find("#whitelisted_identity_id_country").val(data["idCountry"]);
    $addIdentityForm.find("#whitelisted_identity_id_expiry_date").val(data["idExpiryDate"]);
    $addIdentityForm.find("#whitelisted_identity_id_issue_date").val(data["idIssueDate"]);
    $addIdentityForm.find("#whitelisted_identity_partner_id").val(data["partnerId"]);
    $addIdentityForm.find("#whitelisted_identity_full_name").val(data["fullName"]);
    $addIdentityForm.find("#whitelisted_identity_first_name").val(data["firstName"]);
    $addIdentityForm.find("#whitelisted_identity_last_name").val(data["lastName"]);
    $addIdentityForm.find("#whitelisted_identity_first_used_with_txn_id").val(data["inwardRemittanceId"]);
    $addIdentityForm.find("#whitelisted_identity_last_used_with_txn_id").val(data["inwardRemittanceId"]);
    $addIdentityForm.find("#whitelisted_identity_bene_account_no").val(data["beneAccountNo"]);
    $addIdentityForm.find("#whitelisted_identity_bene_account_ifsc").val(data["beneAccountIfsc"]);
    $addIdentityForm.find("#whitelisted_identity_rmtr_code").val(data["rmtrCode"]);
    $addIdentityForm.find("#whitelisted_identity_created_for_identity_id").val(data["createdForIdentityId"]);
    $addIdentityForm.find("#whitelisted_identity_created_for_txn_id").val(data["createdForTxnId"]);
    $('#addIdentity').modal();
  });

  var clip1 = new ZeroClipboard($("#d_clip_button1"));
  var clip2 = new ZeroClipboard($("#d_clip_button2"));
  var clip3 = new ZeroClipboard($("#d_clip_button3"));
  var clip4 = new ZeroClipboard($("#d_clip_button4"));
  var clip5 = new ZeroClipboard($("#d_clip_button5"));
});