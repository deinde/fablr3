require 'sinatra'
require 'sinatra/activerecord'
require './model'
require 'bundler/setup'
require 'rack-flash'
set :database, 'sqlite3:fablr.sqlite3'
set :sessions, true 
use Rack::Flash, sweep:true

def current_user
	session[:user_id] ? User.find(session[:user_id]) : nil 
end 

get '/' do
	erb :home 
end 

post '/login' do 
	my_user = User.find_by(username: params[:username])
	if my_user and my_user.password == params[:password]
		session[:user_id] = my_user.id
		flash[:notice] = "You have succesfully logged in"
		redirect to('/member_page')
	else
		flash[:alert] = "There was a problem."
		redirect to('/')
	end 
end 

# post "/posts/:id/edit" do
# 	@post = Post.find(params[:id])
# 	@post.update_attributes(params)
# 	redirect to("/")
# end

get '/sign_up' do
	erb :sign_up
end 

# All Community Posts Form 
get '/member_page' do
	@post = Post.last(10)
	# @user = User.all
	erb :member_page
end

# Creates posts 
post '/member_page' do
	new_post = Post.create(title: params[:post][:title],  body: params[:post][:body], user_id: current_user.id)
	redirect to('/member_page')
end 


post '/sign_up' do 
	new_user = User.create(params[:user])
	session[:user_id] = new_user.id
	flash[:notice] = "New Account Created"
	redirect to('/member_page')
end 

get '/delete_account' do 
	delete_user = User.find_by(id: current_user.id).destroy
	session[:user_id] = nil
	flash[:delete_notice] = "You have deleted your account"
	redirect to('/')
end 

get '/logout' do 
	session[:user_id] = nil
	# flash[:notice] = "You have logged out"
	redirect to('/')
end 

# Creates a unique profile page id 
get '/follow/:id' do
	@relationship = Relationship.new(follower_id: current_user.id, followed_id: params[:id])
	if @relationship.save 
		flash[:notice] = "succesfully followed"
	else 
		flash[:alert] = "Relationship was not saved."
	end 
	redirect back
end 

get '/user_profile/:id' do 
	@user = User.find(params[:id])
  	@posts = @user.posts
	erb :user_profile

end 

get '/profile_page' do
	@users = User.all
	erb :profile_page 
end 

get '/users/:id' do 
	@user = User.find(params[:id])
end 

get '/edit' do 
	erb :edit
end  

post '/edit' do
	@edit_user = current_user
	    # binding.pry
	@edit_user.update(username: params[:user][:username],password: params[:user][:password], email: params[:user][:email])
	session[:user_id] = @edit_user.id
	flash[:notice] = "You have changed your credentials"
	User.find(session[:user_id])
	redirect to('/edit')
end









