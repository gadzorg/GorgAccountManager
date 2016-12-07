include Rails.application.routes.url_helpers

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

  def self.error_during_soce_fusion(user,email,sync_state,error)
    title="#{user.hruid} - La fusion de vos compte a échoué"
    message=message_for_user(user,"
    Bonjour #{user.firstname},

    Une erreur est survenue lors de la fusion de tes comptes Gadz.org et Soce. Cela signifie que tes données Gadz.org n'ont pas pu être entièrement transférées sur le site Soce.
    Un membre de l'équipe support interviendra bientot pour rétablir la situation et te tenir au courant.

    h3. Instructions à destination de l'équipe support
    Developeur référent: @ratatosk

    Etat des fusions :
    | Fusion des infos de base | #{sync_state[:user_infos] ? "OK" : "Erreur"} |
    | Fusion des adresses | #{sync_state[:addresses] ? "OK" : "Erreur"} |
    | Fusion des réseaux sociaux | #{sync_state[:social_links] ? "OK" : "Erreur"} |
    | Fusion des diplomes | #{sync_state[:diploma] ? "OK" : "Erreur"} |

    Message d'erreur :
    #{error.message}
    ")

    JiraIssue.new(
        fields: {
            project: { id: "10001" },
            summary: title,
            description: message,
            customfield_10000: email ,
            issuetype: { id: "1" },
            labels: [ "fusion", "synchro" ]
        }).save
  end

  def self.gaccount_not_synced_fusion(user, email)
    title="#{user.hruid} - La synchronisation avec votre compte GrAM a échoué"
    message=message_for_user(user,"
    Bonjour #{user.firstname},

    Une erreur est survenue lors de la synchronisation avec ton compte GrAM suite à la fusion de tes données Soce et Gadz.org.
    Cela signifie que tes informations ont bien été enregistrées mais n'ont pas pu être propagées sur l'ensemble de nos application.
    Un membre de l'équipe support interviendra bientot pour rétablir la situation et te tenir au courant.

    h3. Instructions à destination de l'équipe support
    Page confluence de diagnostique et de résolution du problème : https://confluence.gadz.org/pages/viewpage.action?pageId=18907243
    Developeur référent: @ratatosk")

    newjira = JiraIssue.new(
        fields: {
            project: { id: "10001" },
            summary: title,
            description: message,
            customfield_10000: email ,
            issuetype: { id: "1" },
            labels: [ "fusion", "synchro" ]
        })

    newjira.save
  end

  def self.message_layout(message)
    "#{message}

    ----
    Ceci est un message automatisé généré par #{root_url} et sera prochainement traité par un membre de l'équipe support Gadz.org.
    Tu peux répondre à ce mail si tu souhaites ajouter des informations complémentaires"
    end

  def self.message_for_user(user,message)

    message_layout("#{message}

    h3. Informations utilisateur
    | UUID | [#{user.uuid}|https://moncompte.gadz.org/admin/info_user?uuid=#{user.uuid}] |
    | Hruid | #{user.hruid} |
    | Prenom | #{user.firstname} |
    | Nom | #{user.lastname} |")
    end



end