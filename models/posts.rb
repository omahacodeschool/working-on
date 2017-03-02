class Posts
	DATABASE = Database.new

	# Initialize based on the requested search parameters (student posts by date)
	def initialize(params)
		@student = params[:student]
		@day = params[:day]
	end

	# Get all posts of the requested student.
	def get_requested_posts_by_name
		posts = DATABASE.all_filtered("name", @student)
	end

	# Get all of the students' posts from the requested date.
	#
	# Returns an array of requested posts.
	def get_posts_by_date
		posts = get_requested_posts_by_name
		requested_posts = []
		posts.each do |date|
			post_day = date.split(",")
			post_day = post_day[0].to_i
			post_day = Time.at(post_day).strftime("%D")
			if post_day == @day
				requested_posts << date
			end
		end
		return requested_posts
	end
end