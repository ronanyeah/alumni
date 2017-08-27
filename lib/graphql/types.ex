defmodule Alumni.Schema.Types do
  use Absinthe.Schema.Notation

  alias Alumni.CohortResolver
  alias Alumni.StudentResolver

  object :campus do
    field :id, :id
    field :name, :string

    field :cohorts, list_of(:cohort), resolve: &CohortResolver.find/3
  end

  object :cohort do
    field :id, :id
    field :campus_id, :id
    field :start_date, :string
    field :end_date, :string

    field :campus, :campus
    field :students, list_of(:student), resolve: &StudentResolver.find/3
  end

  object :student do
    field :id, :id
    field :cohort_id, :id
    field :first_name, :string
    field :last_name, :string
    field :github, :string

    field :cohort, :cohort
  end
end
