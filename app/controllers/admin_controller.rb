class AdminController < ApplicationController
	def stats
		@links_count = Uniqlink.all.count
		@sessions_count = Recoverysession.all.count
		@sms_count = Uniqsms.all.count
	end
end
