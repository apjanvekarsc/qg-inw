class InwRemittanceRule < ApplicationRecord
  include Approval2::ModelAdditions

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  validates_format_of :pattern_beneficiaries, :with => /\A\w[\w\-\(\)\s\r\n]*\z/, :allow_blank => true
  validates_format_of :pattern_corporates, :with => /\A\w[\w\-\(\)\s\r\n]*\z/, :allow_blank => true
  validates_format_of :pattern_individuals, :with => /\A\w[\w\-\(\)\s\r\n]*\z/, :allow_blank => true
  validates_format_of :pattern_remitters, :with => /\A\w[\w\-\(\)\s\r\n]*\z/, :allow_blank => true
  validates_format_of :pattern_salutations, :with => /\A\w[\w\-\(\)\s\r\n]*\z/, :allow_blank => true

  validates_length_of :pattern_beneficiaries, maximum: 16000
  validates_length_of :pattern_corporates, maximum: 16000
  validates_length_of :pattern_individuals, maximum: 16000
  validates_length_of :pattern_remitters, maximum: 16000

  before_validation :squish_patterns

  def squish_patterns
    self.pattern_beneficiaries = pattern_beneficiaries.squeeze(' ').strip.each_line.reject{|x| x.strip == ''}.join unless pattern_beneficiaries.nil?
    self.pattern_corporates = pattern_corporates.squeeze(' ').strip.each_line.reject{|x| x.strip == ''}.join unless pattern_corporates.nil?
    self.pattern_individuals = pattern_individuals.squeeze(' ').strip.each_line.reject{|x| x.strip == ''}.join unless pattern_individuals.nil?
    self.pattern_remitters = pattern_remitters.squeeze(' ').strip.each_line.reject{|x| x.strip == ''}.join unless pattern_remitters.nil?
    self.pattern_salutations = pattern_salutations.squeeze(' ').strip.each_line.reject{|x| x.strip == ''}.join unless pattern_salutations.nil?
  end
end
