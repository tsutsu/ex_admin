defmodule TestExAdmin.Repo do
  use Ecto.Repo,  otp_app: :ex_admin_runtime
  use Scrivener, page_size: 10
end
