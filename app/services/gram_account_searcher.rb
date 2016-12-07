class GramAccountSearcher

  class BlankQuery<StandardError;end

  attr_reader :query, :performed, :search_logger
  alias_method :performed?, :performed

  def initialize(q, opts={})
    self.query=q
    @performed=false
    @search_logger=opts[:search_logger]
  end

  def query=(q)
    @query=q
    @performed=false
  end

  def perform
    if query.blank?
      @search_logger.log("","Recherche vide") if @search_logger
      raise BlankQuery
    end

    id_soce = begin
      Integer(query.gsub(/[a-zA-Z]/,''))
    rescue ArgumentError
      ""
    end

    type="Non trouvé"

    @gram_account||=GramV2Client::Account.where(email: query).first
    type="Email GrAM" if @gram_account
    @gram_account||=GramV2Client::Account.where(hruid: query).first
    type="Hruid" if @gram_account
    @gram_account||=GramV2Client::Account.where(id_soce: id_soce).first
    type="idSoce" if @gram_account

    @search_logger.log(query,type) if @search_logger

    @performed=true
  end

  def uuid
    gram_account&&gram_account.uuid
  end

  def gram_account
    perform unless performed?
    @gram_account
  end


end