## Past Year Scrapper

Developed using Ruby on Rails, by using Mechanize for web scrapping, Rubyzip for zipping on-the-fly, Parallel for concurrent downloading (in the background).  
App available for free under MIT Licence.

#### Current development status: BETA release with basic functionalities working. 

### Special features:

* Search and download past year papers from MMU's [Vlib](vlib.mmu.edu.my) online library!
* Zip files on-the-fly feature
* Download multiple past year paper all at once
* Support single file download API at "/subject_id" 

### Note for developers:

* This project requires background workers and access rights to the tmp folder to run (to store the past year papers temporarily). Hence, it would not run on Heroku (it uses ephemeral storage).
* Set up crontab using whenever gem to auto clear the temp files
* Set up student_id and student_password in environment variables to access Vlib. The app automatically updates and maintains the session.

### How to run:
* Use a server
* Use localhost by running rails s. Be sure to clear your tmp folder or set up crontab using whenever --update-crontab command

### To do list (Welcome to contribute)

* Exception handling (for session errors)
* UI improvements
* Upgrade to using web sockets instead of using polling
* Any other relevant pull requests would be accepted.



