defmodule Alumni.Schema do
  use Absinthe.Schema
  import_types Alumni.Schema.Types

  query do
    field :all_campuses, list_of(:campus) do
      resolve &Alumni.CampusResolver.all/2
    end
  end
end
