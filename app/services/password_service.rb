class PasswordService
    def self.validate_password_rules password
        password == I18n.transliterate(password) && password.size >= 7
    end
end