class GramAccountSearcher

  class BlankQuery<StandardError;end
  class GorgmailAuthentificationError<StandardError;end

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

    @gram_account ||= search_gram_email(query)
    type="Email GrAM" if @gram_account

    if @gram_account.nil?
      @gram_account = search_gorgmail_email(query)
      type="Email GorgMail" if @gram_account
    end

    if @gram_account.nil?
      @gram_account = search_gram_hruid(query)
      type="Hruid" if @gram_account
    end

    if @gram_account.nil?
      @gram_account = search_gram_idsoce(id_soce)
      type="idSoce" if @gram_account
    end

    @search_logger.log(query,type) if @search_logger

    @performed=true
  end

  def search_gram_email(query)
    GramV2Client::Account.where(email: query)&.first
  end

  def search_gram_hruid(query)
    GramV2Client::Account.where(hruid: query)&.first
  end

  def search_gram_idsoce(query)
    GramV2Client::Account.where(id_soce: query)&.first
  end

  def search_gorgmail_email(query)
    uri=URI::join(Rails.application.secrets.gorgmail_api_url, "search/", CGI.escape(query))

    req = Net::HTTP::Get.new(uri)
    req.basic_auth Rails.application.secrets.gorgmail_api_user, Rails.application.secrets.gorgmail_api_password

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
        http.request(req)
      }

      case response.code
        when "404"
          return nil
        when "200"
          my_uuid=JSON.parse(response.body)["uuid"]
          return GramV2Client::Account.find(my_uuid)
        when "401", "403"
          raise GorgmailAuthentificationError
        else
          raise
        end
    rescue SocketError, Timeout::Error => e
      Rails.logger.error "Gorgmail API unavailable. URL=#{uri}, Error = #{e}"
      return nil
    end
  end


  def uuid
    gram_account&&gram_account.uuid
  end

  def gram_account
    perform unless performed?
    @gram_account
  end


end
