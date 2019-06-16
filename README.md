## Deprecation Notice
This project has been deprecated. It was written when I first started to learn coding, hence the codebase and implementation is messy af, making recreating the project from scratch to be much feasible.

I have decided to revamp this project with a cleaner codebase and faster performance using NodeJS. You may find it [here](https://github.com/dannyongtey/past-year-backend).

You are still welcome to make changes to this project, even though I'm not maintaining it anymore. Currently the main scrapper has ceased to work and the project dependencies have vulnerabilities.

## Past Year Scrapper

Developed using Ruby on Rails, by using Mechanize for web scrapping, Rubyzip for zipping on-the-fly, Parallel for concurrent downloading (in the background).  
App available for free under MIT Licence.

<del>#### Current development status: BETA release with basic functionalities working. </del>

#### Current development status: ABANDONED Codebase available for public use, however might need some tweaking to get it working again.

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



