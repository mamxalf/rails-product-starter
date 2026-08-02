class App::DashboardsController < App::BaseController
  def show
    render inertia: "app/Dashboard"
  end
end
