Start server: `mix phx.server`  
Build client: `elm-make Main.elm --output ../priv/static/bundle.js`  
Watch client: `chokidar '*.elm' -c 'elm-make --debug --warn Main.elm --output ../priv/static/bundle.js'`
