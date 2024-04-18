module InwardRemittanceHelper
  def find_logs(params,transaction)
    if params[:step_name] != 'ALL'
      transaction.audit_steps.where('step_name=?',params[:step_name]).order("attempt_no desc") rescue []
    else
      transaction.audit_steps.order("id desc") rescue []
    end
  end

  def link_to_whitelisted_identity_path(inward_remittance, party)
    wl_id = inward_remittance.send("#{party}_wl_id")
    if wl_id.nil?
      if inward_remittance.send("#{party}_needs_wl") == 'Y'
        if inward_remittance.partner.will_send_id == 'Y'
          if party == 'rmtr' && inward_remittance.rmtr_identity_count > 0
            return link_to 'Required : Add', :controller => "whitelisted_identities",action: "new",id_id: inward_remittance.remitter_identities.first, id_for: party[0].upcase
          end
          if party == 'bene' && inward_remittance.bene_identity_count > 0
            return link_to "Required : Add", :controller => "whitelisted_identities",action: "new", id_id: inward_remittance.beneficiary_identities.first, id_for: party[0].upcase
          end
        end
        # the partner will send id but didnt send any, or the partner doesnt send the id at all
        link_to "Required : Add", :controller => "whitelisted_identities",action: "new", inw_id: inward_remittance.id, id_for: party[0].upcase
      else
        '-'
      end
    else
      link_to 'show', whitelisted_identity_path(wl_id)
    end
  end

  def find_inward_remittances(params)
    inward_remittances = (params[:approval_status].present? and params[:approval_status] == 'U') ? InwardRemittance.unscoped : InwardRemittance
    inward_remittances = inward_remittances.where("partner_code IN (?)",params[:partner_code].split(",").collect(&:strip)) if params[:partner_code].present?
    inward_remittances = inward_remittances.where("status_code = ?", params[:status_code]) if params[:status_code].present?
    inward_remittances = inward_remittances.where("notify_status = ?", params[:notify_status]) if params[:notify_status].present?
    inward_remittances = inward_remittances.where("req_no IN (?)",params[:request_no].split(",").collect(&:strip)) if params[:request_no].present?
    inward_remittances = inward_remittances.where("rmtr_code IN (?)",params[:rmtr_code].split(",").collect(&:strip)) if params[:rmtr_code].present?
    inward_remittances = inward_remittances.where("bene_account_no IN (?)",params[:bene_account_no].split(",").collect(&:strip)) if params[:bene_account_no].present?
    inward_remittances = inward_remittances.where("bene_account_ifsc IN (?)",params[:bene_account_ifsc].split(",").collect(&:strip)) if params[:bene_account_ifsc].present?
    inward_remittances = inward_remittances.where("bank_ref IN (?)",params[:bank_ref].split(",").collect(&:strip)) if params[:bank_ref].present?
    inward_remittances = inward_remittances.where("rmtr_full_name IN (?)",params[:rmtr_full_name].split(",").collect(&:strip)) if params[:rmtr_full_name].present?
    inward_remittances = inward_remittances.where("req_transfer_type IN (?)",params[:req_transfer_type].split(",").collect(&:strip)) if params[:req_transfer_type].present?
    inward_remittances = inward_remittances.where("transfer_type = ?", params[:transfer_type]) if params[:transfer_type].present?
    inward_remittances = inward_remittances.where("transfer_amount>=? and transfer_amount<=?",params[:from_transfer_amount].to_f,params[:to_transfer_amount].to_f) if params[:from_transfer_amount].present? and params[:to_transfer_amount].present?
    inward_remittances = inward_remittances.where("req_timestamp>=? and req_timestamp<=?",Time.zone.parse(params[:from_req_timestamp1]).beginning_of_day,Time.zone.parse(params[:to_req_timestamp1]).end_of_day) if params[:from_req_timestamp1].present? and params[:to_req_timestamp1].present?
    inward_remittances
  end


end
