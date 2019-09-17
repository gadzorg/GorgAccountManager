class SoceDatabaseConnection < ActiveRecord::Base
	establish_connection ENV['SOCE_DATABASE_URL']||"soce_#{Rails.env}".to_sym

	def self.abstract_class?
		true
	end


	def self.custom_sql_query(query,connection_model)
      connection = connection_model
      sql = query

      result = connection.connection.execute(sql);
      h=result.each(:as => :hash) do |row| 
        row["44"] 
      end
      #return empty array if no results ( hash full of nil )
      if result.map{|a| a.compact.present? }.include? true 
        return(h)
      else
        return(Array.new())
      end
    end

end
