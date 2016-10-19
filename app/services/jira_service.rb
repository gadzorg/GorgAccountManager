
class JiraService
  def self.create_recovery_ticket(user, description, sender)
    newjira = JiraIssue.new(
        fields: {
            project: { id: "10001" },
            summary: "L'utilisateur #{user} signale ne pas arriver à se connecter",
            description: description,
            customfield_10000: sender ,
            issuetype: { id: "1" },
            labels: [ "mdp" ]
        })
    newjira.save
  end

  def self.support_message(name,firstname,email,birthdate,phone,desc)
    message = (
    "Nom: " + name +
        "\nPrenom: " + firstname +
        "\nEmail: " + email +
        "\nDate de naissance: " + birthdate +
        "\nTéléphone: " + phone +
        "\n\n" + desc )
  end
end