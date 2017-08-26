require('dotenv').config()

const webpack = require('webpack')
const { resolve } = require('path')

const outputPath = resolve('../public')

const PROD = process.env.NODE_ENV === 'production'

module.exports = {
  entry: resolve(__dirname, 'index.js'),
  output: {
    path: outputPath,
    filename: 'bundle.js'
  },
  devServer: {
    contentBase: '../public'
  },
  plugins: [
    new webpack.DefinePlugin({
      GRAPHQL_ENDPOINT: JSON.stringify(PROD ? process.env.GRAPHCOOL : 'http://localhost:4000/graph'),
      GITHUB_ID: JSON.stringify(process.env.GITHUB_ID || ''),
      GITHUB_SECRET: JSON.stringify(process.env.GITHUB_SECRET || '')
    }),
    ...PROD
      ? [ new webpack.optimize.UglifyJsPlugin() ]
      : []
  ],
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/, /serve/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
          cwd: __dirname,
          debug: !PROD,
          warn: !PROD
        }
      }
    }]
  }
}
