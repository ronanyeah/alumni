defmodule Wow.Schema do
  use Absinthe.Schema
  import_types Wow.Schema.Types

  query do
    field :all_campuses, list_of(:campus) do
      resolve &Wow.CampusResolver.all/2
    end
  end
end
