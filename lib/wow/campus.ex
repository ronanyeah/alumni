defmodule Wow.Campus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wow.Campus


  schema "campuses" do
    field :name, :string

    has_many :cohorts, Wow.Cohort, foreign_key: :campus_id

    timestamps()
  end

  @doc false
  def changeset(%Campus{} = campus, attrs) do
    campus
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
