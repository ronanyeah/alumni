defmodule Wow.Cohort do
  use Ecto.Schema
  import Ecto.Changeset
  alias Wow.Cohort


  schema "cohorts" do
    field :start_date, :date
    field :end_date, :date

    belongs_to :campuses, Wow.Campus, foreign_key: :campus_id
    has_many :students, Wow.Student, foreign_key: :cohort_id

    timestamps()
  end

  @doc false
  def changeset(%Cohort{} = cohort, attrs) do
    cohort
    |> cast(attrs, [:campus_id, :start_date, :end_date])
    |> validate_required([:campus_id, :start_date, :end_date])
  end
end
