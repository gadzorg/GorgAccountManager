class PasswordService
    def self.validate_password_rules password
        password == I18n.transliterate(password) && password.size >= 7
    end

    def self.update_soce_and_gram_password(user_uuid, password)
      user_from_gram = GramV2Client::Account.find(user_uuid)
      @hruid = user_from_gram.hruid
      user_from_soce = Soce::User.where(hruid: @hruid).take

      passwd_hash = Digest::SHA1.hexdigest password
      user_from_gram.password = passwd_hash
      user_from_soce.pass_crypt = passwd_hash unless user_from_soce.nil?

      user_from_gram_saved = user_from_gram.save
      user_from_soce_saved = user_from_soce.save unless user_from_soce.nil?

      return user_from_gram_saved, user_from_soce_saved
    end

end