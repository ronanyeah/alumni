const { resolve } = require('path');

const outputPath = resolve('../priv/static');

module.exports = {
  entry: resolve(__dirname + '/index.js'),
  output: {
    path: outputPath,
    filename: 'bundle.js'
  },
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/, /serve/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
          cwd: __dirname,
          debug: true,
          warn: true
        }
      }
    }]
  }
};
