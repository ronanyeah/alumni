defmodule Wow.Schema do
  use Absinthe.Schema
  import_types Wow.Schema.Types

  query do
    field :campuses, list_of(:campus) do
      resolve &Wow.CampusResolver.all/2
    end

    field :cohorts, list_of(:cohort) do
      resolve &Wow.CohortResolver.all/2
    end

    field :students, list_of(:student) do
      resolve &Wow.StudentResolver.all/2
    end
  end
end
