class Soce::Medal < Soce::Base
	self.table_name = "liens_users_medailles"

	belongs_to :user, foreign_key: "id_user"

	def self.serialize
		hruid = self.first.user.hruid
		sql = "SELECT m.*, annee
        FROM users as u
        left join liens_users_medailles as um on um.id_user = u.id_user
        left join medailles as m on m.id_medaille = um.id_medaille
        where hruid = '#{hruid}'"

        SoceDatabaseConnection.custom_sql_query(sql,SoceDatabaseConnection)
	end

	def self.get_id_medal_for!(name)
		safe_name=Mysql2::Client.escape(name)
		sql="SELECT id_medaille FROM int_anakrys_soce.medailles WHERE libelle='#{safe_name}';"
		obj=SoceDatabaseConnection.custom_sql_query(sql,SoceDatabaseConnection).first
		obj && obj['id_medaille']
	end


end
