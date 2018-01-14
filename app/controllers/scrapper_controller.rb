class ScrapperController < ApplicationController
	include SessionsHelper
	before_action :set_agent, only: [:scrape, :fetch, :singledl] 
	def index
		#debugger
	end

	def scrape
		#REGEX pattern for acceptable subject codes

		subjects = scan_subjects(subject_params)
		if subjects
			@user = create_and_set_session
			@subject_hash = {}
			file_count = 0
			#Extract ID of each subject
			subjects.each do |subject_code|
					@agent.get(url_for_subject(subject_code))
					subject_name = remove_linktext_from_agent(text: subject_code, agent: @agent)
					@subject_hash[subject_code] = {}
					@subject_hash[subject_code][:name] = subject_name
					@subject_hash[subject_code][:ids] = [] 
					links = @agent.page.links_with(text: "Fulltext View")
					#Insert each ID of the subject into hash
					links.each do |link|
						@subject_hash[subject_code][:ids] <<  link.uri.to_s.split('=').last
					end
					file_count += links.count
			end
			@user.update_attributes(count: file_count)
			#Delayed::Job.enqueue(DownloadJob.new(session[:id], @subject_hash))
			@user.add_to_queue(@subject_hash)

			User.delay.download(@user.session)
			#debugger
		else
			# Failure code
			flash[:danger] = "Error in input. Please follow the guidelines."
			redirect_to root_path
		end

	end

	def singledl

		id = subject_params[:sub_id]
		dl_link = "http://vlibcm.mmu.edu.my.proxyvlib.mmu.edu.my//xzamp/gxzam.php?action=#{id}.pdf"
		data = @agent.post(dl_link).body
		send_data data, filename: "#{id}.pdf", type: "application/pdf", disposition: "attachment"

	end

	def check
		user = User.find_by(session: session[:id])
		@done = false
		@count = user.temp_files.all.map{|x| !!x.path }.count(true)

		if user.count == @count
			@done = true
		end
		
		respond_to do |format|
			format.js {
				render 'polling.js.erb'
			}
		end
	end

	def fetch
		
		#Sample link: http://vlibcm.mmu.edu.my.proxyvlib.mmu.edu.my//xzamp/gxzam.php?action=35379.pdf
		#if session = session[:id]
		user = User.find_by(session: params[:session])
		#user = Session.find_by(session: session)
		t = Tempfile.new("temp-#{SecureRandom.hex}")
		Zip::OutputStream.open(t.path) do |zos|
			params[:subject].each do |subject|
				#debugger
				subject_files = user.temp_files.where("path LIKE ?", "%#{subject}%")
				subject_files = subject_files.map(&:path)
				subject_files.each do |file_path|
					id = file_path.split("-")[2]
					#debugger
					zos.put_next_entry("#{subject}/#{id}.pdf")
					zos.print IO.read(file_path)
				end
			end
		end
		zip_data = File.read(t.path)
		send_data zip_data, type: "application/zip", disposition: "attachment", filename: "past-year.zip"
		t.close
		t.unlink
	#else
		flash[:danger] = "Unauthorized access to file"
		#redirect_to root_path
	#end
	end

		
	

	private
	def subject_params
		params.permit(:sub_id)
	end


	def set_agent
			@agent = Mechanize.new
			@agent.user_agent_alias = "Mac Safari" 
			update_or_initialize_cookie(@agent)
			@agent.cookie_jar.load("cookies.yaml")
	end

	def scan_subjects (parameter)
		pattern = /^[A-Z]{3}[0-9]{4}$/ 
		temp_array = subject_params[:sub_id].upcase.delete(' ').split(",")

		subject_array = []
		temp_array.each do |item|
			if pattern.match(item)
				subject_array << item.insert(3, ' ') #Add space for subject so TSN1101 becomes TSN 1101
			else
				return false
			end
		end
		subject_array
	end

	def url_for_subject(code)
		search_url = "http://library.mmu.edu.my.proxyvlib.mmu.edu.my/library2/diglib/exam_col/resindex.php?df1=title&rt=#{code.split(" ").first}%20#{code.split(" ").second}&ph1=%&cmp1=&df2=&ra=&ph2=&cmp2=&ri=&rp=&rf=&ry1=&ry2=&df3=title&std=ASC&page=0&limit=50"
	end

	def update_or_initialize_cookie(agent)
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

	def remove_linktext_from_agent(text: "", agent:)
		return nil if agent.nil?
		
		#Require exception handling
		mod_text = agent.page.link_with(text: /#{text}/).text
		return nil if mod_text.nil?
		mod_text.slice! (text)
		mod_text.to_sym
	end



end
