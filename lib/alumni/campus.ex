defmodule Alumni.Campus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Alumni.Campus

  schema "campuses" do
    field :name, :string

    has_many :cohorts, Alumni.Cohort, foreign_key: :campus_id

    timestamps()
  end

  @doc false
  def changeset(%Campus{} = campus, attrs) do
    campus
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
