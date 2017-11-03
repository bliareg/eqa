Warden::Manager.after_authentication do |user, _auth, _opts|
  if user.instance_of? User
    user.statistics.create
  end
end

Warden::Manager.after_set_user do |user, _auth, _opts|
  if user.instance_of? User
    user.statistics.last.update(updated_at: Time.now)
  end
end
