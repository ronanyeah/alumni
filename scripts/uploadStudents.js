const fetch = require("node-fetch");

const { COHORT_ID, GC_TOKEN, GRAPHQL_ENDPOINT } = process.env;

// [{ firstName: String, github: String }]
const students = require("./data.json");

const createStudent = (firstName, github) =>
  fetch(GRAPHQL_ENDPOINT, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${GC_TOKEN}`
    },
    body: JSON.stringify({
      query: `
        mutation {
          createStudent(
            cohortId: "${COHORT_ID}"
            firstName: "${firstName}"
            github: "${github}"
          ) {
            id
          }
        }
      `
    })
  }).then(res => res.json());

Promise.all(
  students.map(({ firstName, github }) => createStudent(firstName, github))
)
  .then(console.log)
  .catch(console.error);
