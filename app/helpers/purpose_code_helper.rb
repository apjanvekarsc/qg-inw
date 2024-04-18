module PurposeCodeHelper
  # the options for the multi select are stored as a string in the database
  # while in the views we need an array, this helper helps!
  def convert_options_to_array(options_as_string)
    if (!options_as_string.nil?)
      options_as_string.split(',')
    else 
      []
    end
  end

  
  def disallowed_bene_and_rem_types_on_show_page(value)
    if (value == "I,C")
      "Individual,Corporates"
    elsif (value == "I")
      "Individual"
    elsif (value == "C")
      "Corporates"
    end
  end

  def find_purpose_codes(params)
    purpose_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? PurposeCode.unscoped : PurposeCode
    purpose_codes = purpose_codes.where("is_enabled = ?", params[:is_enabled]) if params[:is_enabled].present?
    purpose_codes = purpose_codes.where("code IN (?)",params[:code].split(",").collect(&:strip)) if params[:code].present?
    purpose_codes
  end

end