class Soce::Diploma < Soce::Base
	self.table_name = "users_diplomes"

	belongs_to :user, foreign_key: "id_user"

	def self.serialize
		hruid = self.first.user.hruid
		sql = "SELECT ud.*
        FROM users as u
        left join users_diplomes as ud on u.id_user = ud.id_user
        where hruid = '#{hruid}'"

        SoceDatabaseConnection.custom_sql_query(sql,SoceDatabaseConnection)
	end


end
