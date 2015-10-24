class Recoverymailer < ApplicationMailer
	default from: 'notifications@example.com'
   
   def recovery_email(email,url,hruid)
   	  @hruid = hruid
   	  @url = url
      mail(to: email, subject: 'Recupération de mot de passe')
   end
end

