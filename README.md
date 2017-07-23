Start server: `mix phx.server`
Build client: `elm-make Main.elm --output ../priv/static/bundle.js`
Watch client: `nodemon -e elm -x 'elm-make --debug --warn Main.elm --output ../priv/static/bundle.js'`
