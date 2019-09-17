require "digest/sha1"

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null
# primary key
#  email                  :string           default("")
# not null
#  encrypted_password     :string           default("")
# not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
# not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  hruid                  :string
#  firstname              :string
#  lastname               :string
#  role_id                :integer
#  last_gram_sync_at      :datetime
#

require "faker"

FactoryBot.define do
  factory :soce_user, class: Soce::User do
    id_user { rand(90_000) + 30_000 }
    id_user_chksum { ((id_user % 23) + 65).chr }
    id_civilite { 1 }
    id_type_societaire { 11 }
    id_conjoint { nil }
    nom { Faker::Name.last_name }
    prenom { Faker::Name.first_name }
    nom_jeune_fille { Faker::Name.last_name }
    parente { nil }
    date_naissance { Faker::Date.between(from: 60.years.ago, to: 18.years.ago) }
    login { "#{id_user}#{id_user_chksum}" }
    pass { "" }
    pass_crypt { Digest::SHA1.hexdigest Devise.friendly_token[0, 20] }
    email { Faker::Internet.email }
    email_valide { "1" }
    email_secondaire { nil }
    id_ensam { "" }
    promo1 { "2011" }
    promo2 { "0" }
    promo3 { "0" }
    centre1 { "9" }
    centre2 { "0" }
    centre3 { "0" }
    filiere1 { "1" }
    filiere2 { "0" }
    filiere3 { "0" }
    id_membre_associe { nil }
    id_type_associe { nil }
    tel_mobile { "33623456789" }
    date_creation { "2011-08-26 00:00:00" }
    date_maj { "2016-11-28 00:00:00" }
    sexe { "H" }
    figuration_annuaire { "0" }
    figuration_annuaire_adr_perso { "1" }
    figuration_annuaire_adr_pro { "1" }
    figuration_email { "0" }
    figuration_externe { "0" }
    figuration_web { "0" }
    figuration_web_adr_perso { "1" }
    figuration_web_adr_pro { "1" }
    date_sortie { "2014-10-09" }
    date_adhesion { "2014-11-05" }
    date_readhesion { nil }
    date_demission { nil }
    date_deces { nil }
    date_radiation { nil }
    date_relance_cotis { "2016-01-13" }
    date_ouverture_img_relance_cotis { "2016-01-14 10:08:45" }
    type_reception_annuaire { nil }
    modif { nil }
    date_validation { nil }
    adresseip { nil }
    photo { "photo_102096.jpg" }
    cot_ar0 { "2016" }
    cot_ar1 { "0" }
    cot_ar2 { "0" }
    cot_ar3 { "0" }
    nb_cot { "1" }
    type_abt { "0" }
    fin_abt { nil }
    nb_abt { "0" }
    date_fin_amm_web { nil }
    relance_amm { "1" }
    annuaire_encours { nil }
    surnom { "ratatosk" }
    buque_zaloeil { "Ratatosk" }
    famille1 { "157" }
    famille2 { "" }
    famille3 { "" }
    famille_zaloeil { "157" }
    id_users_parente { nil }
    date_radiation2 { nil }
    premiere_connexion { "0" }
    date_maj_paiement { "2015-02-19" }
    dernier_annee_cotiz_associe { nil }
    dernier_annee_cotiz_cg { nil }
    total_arriere { nil }
    date_declaration_deces { nil }
    date_dernier_changement_mdp { nil }
    created_at { "2011-08-26 19:05:24" }
    updated_at { "2016-11-28 11:04:09" }
    trans_pay_siam { "0" }
    annuaire_expedie { "0" }
    id_filiere { "0" }
    id_sous_filiere { "0" }
    annee_filiere { "0" }
    societe_externe { nil }
    donnees_pro_paristech { "0" }
    donnees_perso_paristech { "0" }
    abonnement_veuve { nil }
    date_originale_fin_abo_amm { nil }
    fonction_externe { nil }
    promo_externe { nil }
    ecole_externe { nil }
    carte_de_membre_editee { "0" }
    adhesion_recue { "1" }
    adhesion_avis { "F" }
    id_centre_dsc { "0" }
    date_passage_membre_a_vie { nil }
    forlife_gadz_org { nil }
    bestalias_gadz_org { nil }
    autoriser_diffusion_vers_gadz_org { "0" }
    autoriser_diffusion_vers_cge { "0" }
    rapel_imelavi { nil }
    societe_manif_externe { nil }
    cursus_manif_externe { nil }
    motif_exoneration { nil }
    bloquer_transfert_isf { "0" }
    autoriser_diffusion_ecole { "1" }
    bloquer_com_email { "0" }
    compte_desactive { "0" }
    date_rappel_maj_coordonnees { "2016-11-09" }
    date_limite_bloquage_relance_cotiz { nil }
    date_effacement_si_compte_temporaire { nil }
    hruid { "alexandre.narbonne.2011" }
    linkedin { nil }
    id_bande { "0" }
    a_propos_de_moi { "" }
    figuration_annuaire_publique { "1" }
    is_gadzart { "1" }
    uuid { "8046ee4d-2bce-4eec-bc57-c4146753298a" }
    migration_platal { "1" }
    date_migration_platal { "2016-11-18" }
  end
end
