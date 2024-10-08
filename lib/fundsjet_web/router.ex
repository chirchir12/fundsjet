defmodule FundsjetWeb.Router do
  use FundsjetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FundsjetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :maybe_auth do
    plug FundsjetWeb.Pipelines.MybeAuthPipeline
  end

  pipeline :require_auth do
    plug FundsjetWeb.Pipelines.EnsureAuthPipeline
  end

  scope("/v1", FundsjetWeb) do
    pipe_through [:api]

    post "/auth/login", AuthController, :login
    post "/auth/register", AuthController, :register

    post "/auth/token/renew", AuthController, :refresh_token
    post "/auth/token/revoke", AuthController, :revoke_refresh_token
  end

  scope "/v1/", FundsjetWeb do
    pipe_through [:api, :maybe_auth, :require_auth]

    get "/users", UserController, :index
    get "/users/:id", UserController, :show
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    post "/customers", CustomerController, :create
    get "/customers", CustomerController, :index
    get "/customers/:id", CustomerController, :show
    put "/customers/:id", CustomerController, :update
    delete "/customers/:id", CustomerController, :delete

    post "/products", ProductController, :create
    get "/products", ProductController, :index
    get "/products/:id", ProductController, :show
    put "/products/:id", ProductController, :update
    delete "/products/:id", ProductController, :delete

    post "/products/:product_id/configuration", ProductController, :create_configuration
    get "/products/:product_id/configuration", ProductController, :list_configuration
    put "/products/configuration/:id", ProductController, :update_configuration
    delete "/products/configuration/:id", ProductController, :delete_configuration

    post "/loans/:product_id", LoanController, :create
    get "/loans", LoanController, :index
    get "/loans/:id", LoanController, :show

    post "/loans/:id/add/reviewer", LoanController, :add_loan_reviewer
    get "/loans/:id/reviews", LoanController, :list_loan_reviews
    put "/loans/:id/review", LoanController, :add_loan_review
    put "/loans/:id/approve", LoanController, :approve_loan
    put "/loans/:id/disburse", LoanController, :disburse_loan
    put "/loans/:id/repay", LoanController, :repay_loan
  end

  # Other scopes may use custom stacks.
  # scope "/api", FundsjetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:fundsjet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FundsjetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
