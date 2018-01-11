class User < ApplicationRecord
	has_many :temp_files, dependent: :destroy
	scope :three_minutes_old, {where("created_at >= :3_minutes_ago", 3_minutes_ago: Time.now-3.minutes)}
	scope :old_files, {temp_files.where("created_at >= :3_minutes_ago", 3_minutes_ago: Time.now-3.minutes)}
	
	def download(agent, sub_hash)
		#self.temp_files.create!(path: "huehue")

		subject_hash = User.filter_params(sub_hash)

		#Maybe use back scan_subject function
		#t = Tempfile.new("temp-#{SecureRandom.hex}")
		#Zip::OutputStream.open(t.path) do |zos|
		
		subject_hash.each do |subject, ids|
		  #Parallel.each(ids, in_processes: ids.count) do |id|
			ids.each do |id|
			
				
				dl_link = "http://vlibcm.mmu.edu.my.proxyvlib.mmu.edu.my//xzamp/gxzam.php?action=#{id}.pdf"
				temp_agent = agent.dup
				data = temp_agent.post(dl_link).body

				t = Tempfile.new("temp-#{subject}-#{id}-", encoding: "ascii-8bit")
				t.write(data)
				self.temp_files.create(path: t.path)
				t.close
				ObjectSpace.undefine_finalizer(t)
	
				end			
		end
		#self.temp_files.create(path: "haha")
	end

	def self.filter_params(parameter)
		
		filtered_params = {}
		parameter.each do |key, value|
			break if key == "controller" || key == "action" || key == "data"
		
			filtered_params[key.to_sym] = value[:ids]
		end
		filtered_params
	end

	def self.set_agent
			@agent = Mechanize.new
			@agent.user_agent_alias = "Mac Safari" 
			update_or_initialize_cookie(@agent)
			@agent.cookie_jar.load("cookies.yaml")
	end

	def self.update_or_initialize_cookie(agent)
		stud_id = ENV["student_id"]
		stud_pswd = ENV["student_password"]

		test_subject = "TSN 1101"
		if File.exist?("cookies.yaml")
			agent.cookie_jar.load("cookies.yaml")
		end

		agent.get url_for_subject(test_subject)

		if agent.page.title == "Off-campus Login"
			agent.page.form.user = stud_id
			agent.page.form.pass = stud_pswd
			agent.page.form.submit
		end
		agent.cookie_jar.save("cookies.yaml", session: true)
		
	end	
end
