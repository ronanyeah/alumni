defmodule Wow.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Wow.Repo

  object :campus do
    field :id, :id
    field :name, :string

    field :cohorts, list_of(:cohort), resolve: assoc(:cohorts)
  end

  object :cohort do
    field :id, :id
    field :campus_id, :id
    field :start_date, :string
    field :end_date, :string

    field :campus, :campus, resolve: assoc(:campuses)
    field :students, list_of(:student), resolve: assoc(:students)
  end

  object :student do
    field :id, :id
    field :cohort_id, :id
    field :first_name, :string
    field :last_name, :string
    field :github, :string

    field :cohort, :cohort, resolve: assoc(:cohorts)
  end
end
