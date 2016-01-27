class InscriptionMailer < ApplicationMailer
	def inscription_email(email,url,nom, prenom)
   	  @nom = nom
   	  @prenom = prenom
   	  @url = url

      mail(to: email, subject: 'Ton adresse Gadz.org arrive!')
   end
end
