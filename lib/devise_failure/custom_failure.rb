class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_message == :unconfirmed
      "/unconfirmed?email=#{params[:user][:email]}"
    else
      super
    end
  end

  # You need to override respond to eliminate recall
  def respond
    if warden_message == :unconfirmed
      redirect
    else
      super
    end
  end
end
