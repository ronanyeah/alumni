alias Wow.Repo

alias Wow.Campus
alias Wow.Cohort
alias Wow.Student

Repo.delete_all Student
Repo.delete_all Cohort
Repo.delete_all Campus

for _ <- 1..3 do
  %Campus{ id: campus_id } = Repo.insert!(%Campus{
    name: Faker.Address.city
  })

  for _ <- 1..3 do
    start_date = Faker.Date.backward(1000)

    end_date =
      start_date
      |> Date.to_erl
      |> :calendar.date_to_gregorian_days
      |> Kernel.+(90)
      |> :calendar.gregorian_days_to_date
      |> Date.from_erl!

    %Cohort{ id: cohort_id } = Repo.insert!(%Cohort{
      start_date: start_date,
      end_date: end_date,
      campus_id: campus_id
    })

    for _ <- 1..16, do:
      Repo.insert!(%Student{
        first_name: Faker.Name.first_name,
        last_name: Faker.Name.last_name,
        github: Faker.Pokemon.name,
        cohort_id: cohort_id
      })
  end
end
