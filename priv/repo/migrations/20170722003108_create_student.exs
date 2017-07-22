defmodule Wow.Repo.Migrations.CreateWow.Student do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :first_name, :string
      add :last_name, :string
      add :github, :string
      add :cohort_id, references(:cohorts, on_delete: :nothing)

      timestamps()
    end

    create index(:students, [:cohort_id])
  end
end
