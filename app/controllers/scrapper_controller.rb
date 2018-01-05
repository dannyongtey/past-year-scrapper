class ScrapperController < ApplicationController

	def index
	end

	def scrape
		#REGEX pattern for acceptable subject codes
		subjects = scan_subjects(subject_params)
		if subjects

			agent = Mechanize.new
			agent.user_agent_alias = "Mac Safari" 
			update_or_initialize_cookie(agent)
			agent.cookie_jar.load("cookies.yaml")
			@subject_hash = {}
			#Extract ID of each subject
			subjects.each do |subject_code|
					agent.get(url_for_subject(subject_code))
					subject_name = remove_linktext_from_agent(text: subject_code, agent: agent)
					@subject_hash[subject_code] = {}
					@subject_hash[subject_code][:name] = subject_name
					@subject_hash[subject_code][:ids] = [] 
					links = agent.page.links_with(text: "Fulltext View")
					#Insert each ID of the subject into hash
					links.each do |link|
						@subject_hash[subject_code][:ids] <<  link.uri.to_s.split('=').last
					end
			end
			debugger

		else
			# Failure code
			flash[:danger] = "Error in input. Please follow the guidelines."
			redirect_to root_path
		end

	end

	def fetch
		#Sample link: http://vlibcm.mmu.edu.my.proxyvlib.mmu.edu.my//xzamp/gxzam.php?action=35379.pdf
	end

	private
	def subject_params
		params.permit(:sub_id)
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

		agent.cookie_jar.save("cookies.yaml")

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