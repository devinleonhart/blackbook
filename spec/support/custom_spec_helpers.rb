module CustomSpecHelpers
  def login_user(user)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end
  end
end
