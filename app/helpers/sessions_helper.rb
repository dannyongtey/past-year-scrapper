module SessionsHelper
	def create_and_set_session
		random_id = SecureRandom.hex
		user = User.new(session: random_id)
		session[:id] = random_id
		user.save
		user
	end
end
