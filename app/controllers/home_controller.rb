class HomeController < ApplicationController
  def index
    # Redirect logged-in users to their dashboard
    if user_signed_in?
      redirect_to dashboard_path
    end
  end
end
