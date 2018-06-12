defmodule SimpleAuth.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string
      add :password_has, :string
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end
  end
end
