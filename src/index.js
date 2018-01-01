var Elm = require("./Main.elm");

Elm.Main.embed(document.getElementById("app"), [
  GRAPHQL_ENDPOINT,
  GITHUB_TOKEN
]);
