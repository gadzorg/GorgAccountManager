class Supportmailer < ApplicationMailer

	# mailer pour les demandes au support qui sont envoyées à jira
	# il faudra réécrire le from pour que ce ne soit pas celui assocoé au smtp de la boite mail.
	# ou trouver une autre solution pour que l'utilisateur soit rensigné comme sender dans jira.
	def support_email(name,firstname,email,birthdate,phone,desc)
		email_support = "support@gadz.org"

		@name = name
		@firstname = firstname
		@email = email
		@birthdate = birthdate
		@phone = phone
		@desc = desc

		mail(to: email_support, subject: "L'utilisateur #{email} signale ne pas arriver à se connecter")
	end
end
