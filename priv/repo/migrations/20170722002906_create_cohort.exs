defmodule Wow.Repo.Migrations.CreateWow.Cohort do
  use Ecto.Migration

  def change do
    create table(:cohorts) do
      add :start_date, :date
      add :end_date, :date
      add :campus_id, references(:campuses, on_delete: :nothing)

      timestamps()
    end

    create index(:cohorts, [:campus_id])
  end
end
