class EndpointHistory
  include ActiveModel::Model
  attr_accessor :name, :sub_name, :api_version, :availability_history, :provider

  validates :name, presence: true
  validates :api_version, presence: true
  validate :valid_availability_history

  def initialize(hash)
    super
    @availability_history = AvailabilityHistory.new
  end

  def add_ping(code, timestamp)
    @availability_history.add_ping(code, timestamp)
  end

  def sla
    @availability_history.sla
  end

  def id
    if exercices_v1?
      'exercices_etablissements_1'
    elsif eligilite_probtp_v1?
      'eligibilite_cotisation_retraite_probtp_1'
    elsif attestation_probtp_v1?
      'attestations_cotisation_retraite_probtp_1'
    elsif cotisations_msa_v1?
      'cotisations_msa_1'
    elsif opqibi_v1?
      'certificat_opqibi_1'
    elsif infogreffe_v1?
      'extraits_rcs_infogreffe_1'
    elsif cnetp_v1?
      'certificat_cnetp_1'
    elsif fntp_v1?
      'cartes_professionnelles_fntp_1'
    elsif declaration_dgfip_v2?
      'liasses_fiscales_dgfip_declarations_2'
    elsif complete_dgfip_v2?
      'liasses_fiscales_dgfip_complete_2'
    else
      "#{name}_#{sub_name}_#{api_version}".gsub(/ /, '_').downcase
    end
  end

  private

  def valid_availability_history
    availability_history.valid?
  end

  def exercices_v1?
    @name == 'exercices'
  end

  def eligilite_probtp_v1?
    @name == 'eligibilites_cotisation_retraite_probtp'
  end

  def attestation_probtp_v1?
    @name == 'attestations_cotisation_retraite_probtp'
  end

  def cotisations_msa_v1?
    @name == 'msa' && @sub_name == 'cotisations'
  end

  def opqibi_v1?
    @name == 'opqibi' && @sub_name == 'certificat'
  end

  def infogreffe_v1?
    @name == 'infogreffe' && @sub_name == 'extraits_rcs'
  end

  def cnetp_v1?
    @name == 'certificats_cnetp'
  end

  def fntp_v1?
    @name == 'fntp' && @sub_name == 'carte_pro'
  end

  def declaration_dgfip_v2?
    @name == 'liasses_fiscales_dgfip' && @sub_name == 'declaration'
  end

  def complete_dgfip_v2?
    @name == 'liasses_fiscales_dgfip' && @sub_name == 'show'
  end
end
