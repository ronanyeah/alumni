require('dotenv').config()

const webpack = require('webpack');
const { resolve } = require('path');

const outputPath = resolve('../priv/static');

module.exports = {
  entry: resolve(__dirname + '/index.js'),
  output: {
    path: outputPath,
    filename: 'bundle.js'
  },
  plugins: [
    new webpack.DefinePlugin({
      GRAPHQL_ENDPOINT: JSON.stringify(process.env.GRAPHCOOL || '/graph?query='),
      GITHUB_ID: JSON.stringify(process.env.GITHUB_ID || ''),
      GITHUB_SECRET: JSON.stringify(process.env.GITHUB_SECRET || '')
    })
  ],
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
