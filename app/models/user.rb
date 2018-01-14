class User < ApplicationRecord
	has_many :temp_files, dependent: :destroy
	scope :three_minutes_old, ->{where("created_at <= :three_minutes_ago", three_minutes_ago: Time.now-3.minutes)}
	
	def add_to_queue(sub_hash)
		#self.temp_files.create!(path: "huehue")

		subject_hash = User.filter_params(sub_hash)

		#Maybe use back scan_subject function
		#t = Tempfile.new("temp-#{SecureRandom.hex}")
		#Zip::OutputStream.open(t.path) do |zos|
		
		subject_hash.each do |subject, ids|
		  #Parallel.each(ids, in_processes: ids.count) do |id|
			ids.each do |id|
				#Delayed::Worker.logger.debug("Log Entry")

				self.temp_files.create(code: id, subject: subject)

				end			
		end
		#self.temp_files.create(path: "haha")
	end

	def self.download(session)
		
		user = User.find_by(session: session)
		temp_files = user.temp_files
		#ActiveRecord::Base.connection.close
		paths = Parallel.map(temp_files, in_processes: user.count) do |file|
		#user.temp_files.map do |file|
			
			id = file.code
			subject = file.subject
			dl_link = "http://vlibcm.mmu.edu.my.proxyvlib.mmu.edu.my//xzamp/gxzam.php?action=#{id}.pdf"
			
			t = Tempfile.new("temp-#{subject}-#{id}-", encoding: "ascii-8bit")
			#ActiveRecord::Base.connection_pool.with_connection do
			
				
		
			#end
			agent = Mechanize.new
			agent.user_agent_alias = "Mac Safari"
			agent.cookie_jar.load("cookies.yaml")
			#Dummy url
			agent.get("http://library.mmu.edu.my.proxyvlib.mmu.edu.my/library2/diglib/exam_col/resindex.php?df1=title&rt=TSN%201101&ph1=%&cmp1=&df2=&ra=&ph2=&cmp2=&ri=&rp=&rf=&ry1=&ry2=&df3=title&std=ASC&page=0&limit=50")
			agent.post(dl_link)
			data = agent.page.body
			t.write(data)
			t.close
			ObjectSpace.undefine_finalizer(t)
			t.path
		end
		begin
		  ActiveRecord::Base.connection.reconnect!
		rescue
		  ActiveRecord::Base.connection.reconnect!
		end
	
		for i in 0...paths.count
			user.temp_files[i].update_attributes(path: paths[i])
		end
		
	end

	def destroy_old_files
		files = temp_files.where("created_at <= :three_minutes_ago", three_minutes_ago: Time.now-3.minutes)
		files.each do |file|
			File.delete(file.path) if File.exist?(file.path)
		end
	end

	def self.destroy_old_user_and_files
		User.three_minutes_old.each do |user|
			user.destroy_old_files
			user.destroy
		end
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
