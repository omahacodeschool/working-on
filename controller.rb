# Sets 'index.erb' as the homepage.
#
# Sets @login session variable to store student's name for repeat visits.
get "/" do
	@login = session[:login]
	@admin = session[:admin]
	erb :index
end

# Deletes login session variable.
get "/reset" do
	session.delete("login")
	erb :index
end

# Collects the student's post information and adds it to the database.
#
# Redirects back to homepage.
post "/submit" do
	session[:login] = params["name"]
	submission = Submission.new
	submission.create(params)
	redirect("/")
end

# Front page display, gets all posts for current day and formats correctly.
#
# Through JavaScript this controller runs on page load and every 10 seconds to refresh the page content.
# 
# Post content is returned to JavaScript as JSON through an AJAX request.
get "/display" do
	@returnPosts = Posts.front_page_json
	return @returnPosts
end

# Checks username and password against the database (admin table) to verify users'
# login info. If true, username is stored as a session variable to allow access to
# admin pages.
post "/admin_login" do
	login_status = Admin.new(params).check_valid_login
	if login_status == true
		session[:admin] = params[:username]
		redirect("/admin")
	else
		redirect("/")
	end
end

# Deletes admin session variable and returns user to the homepage.
get "/admin_logout" do
	session.delete("admin")
	erb :index
end

# Allows students to login and post their work, redirects user to hompage
post "/student_login" do 
		login_status = Admin.new(params).check_valid_student_login
		if login_status == true
			session[:login] = params["username"]
			redirect("/")
		else
			redirect("/")
		end
end

# Creates a new student user in the students database, using the information inputted on
# the main page. Redirects user to home page.
post "/student_signup" do
		if $database.all_by("students", "name", "#{params["username"]}").ntuples == 0
			Student.first_time_login(params["username"], params["github"], params["password"])
	 		session[:login] = params["username"]
 			redirect("/")
 		else
 			redirect("/")
 		end	
end

# Loads the admin page.
#
# Builds dropdown menus of available student names and dates using the Submission class.
get "/admin" do
	redirect "/" unless session[:admin]
	@admin = session[:admin]
	@names = Submission.names
  @dates = Submission.dates
  erb :admin, :layout => :admin_layout
end

# For admin, gets all posts based on requested search params (student name by date).
#
# Loads getinfo page with the selected search posts.
get "/getinfo" do
	redirect "/" unless session[:admin]
	@admin = session[:admin]
	@names = Submission.names
  @dates = Submission.dates
  @info = Posts.new(params).hold_posts		
  erb :getinfo, :layout => :admin_layout
end