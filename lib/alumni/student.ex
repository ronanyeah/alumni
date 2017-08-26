defmodule Alumni.Student do
  use Ecto.Schema
  import Ecto.Changeset
  alias Alumni.Student


  schema "students" do
    field :first_name, :string
    field :github, :string
    field :last_name, :string

    belongs_to :cohort, Alumni.Cohort, foreign_key: :cohort_id

    timestamps()
  end

  @doc false
  def changeset(%Student{} = student, attrs) do
    student
    |> cast(attrs, [:cohort_id, :first_name, :last_name, :github])
    |> validate_required([:cohort_id, :first_name, :last_name, :github])
  end
end
