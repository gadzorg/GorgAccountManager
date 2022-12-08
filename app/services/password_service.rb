class PasswordService

  #Regles de validation google :
  # - Alphanumérique
  # - ! " # $ % & ‘ ( ) * + , - . / : ; < = > ? @ [ \ ] ^ { | } ~
  # - Don't start or end with a space
  # - 8 char min

  #WARNING : ACCEPTED_CHARS does not contain spaces
  ACCEPTED_CHARS=/[a-zA-Z0-9!\"#$%&'‘()*+,\-.\/:;<=>?@\[\\\]^{|}~]/
  VALIDATION_REGEX=/\A(?! )(#{ACCEPTED_CHARS.to_s}|((?! \Z) )){8,}?\Z/

  def initialize password
    @password=password
    @errors=[]
  end

  def errors
    @errors
  end

  def password
    @password
  end

  def encrypted_password
    Digest::SHA1.hexdigest @password
  end

  def validate
    # !! pour avoir un booléen
    valid=!!(@password =~ VALIDATION_REGEX)
    unless valid
      set_errors
    end
    valid
  end

  def set_errors
    #validate characters
    rejected_chars=@password.split("").reject{|e| e==" "||e=~ACCEPTED_CHARS}
    if rejected_chars.any?
      errors << I18n.t('password_service.errors.illegal_chars', chars: rejected_chars.uniq.join(" "))
    end

    # Password length > 10
    if @password.length < 10
      errors << I18n.t('password_service.errors.too_short')
    end

    #Don't start with space
    if @password[0] == " "
      errors << I18n.t('password_service.errors.start_with_space')
    end

    #Don't end with space
    if @password[-1] == " "
      errors << I18n.t('password_service.errors.end_with_space')
    end
  end

  def update_soce_and_gram_password(user_uuid)
    user_from_gram = GramV2Client::Account.find(user_uuid)
    user_from_soce = Soce::User.where(uuid: user_uuid).take

    user_from_gram.password = encrypted_password
    user_from_soce.pass_crypt = encrypted_password unless user_from_soce.nil?

    user_from_gram_saved = user_from_gram.save
    user_from_soce_saved = user_from_soce.save unless user_from_soce.nil?

    return user_from_gram_saved, user_from_soce_saved
  end

end
