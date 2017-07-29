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

    field :campus, type: :campus do
      arg :id, non_null(:id)
      resolve &Wow.CampusResolver.find/2
    end

    mutation do
      field :cohort, type: :cohort do
        arg :campus_id, non_null(:string)
        arg :start_date, non_null(:string)
        arg :end_date, non_null(:string)

        resolve &Wow.CohortResolver.create/2
      end

      field :student, type: :student do
        arg :cohort_id, non_null(:string)
        arg :first_name, non_null(:string)
        arg :last_name, non_null(:string)
        arg :github, non_null(:string)

        resolve &Wow.StudentResolver.create/2
      end
    end
  end
end
