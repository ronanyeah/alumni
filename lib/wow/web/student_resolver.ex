defmodule Wow.StudentResolver do
  alias Wow.{Student, Repo}

  def all(_args, _info) do
    {:ok, Repo.all(Student)}
  end
end
