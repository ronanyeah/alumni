const webpack = require('webpack')
const { resolve } = require('path')

const PROD = process.env.NODE_ENV === 'production'

if (!PROD) {
  require('dotenv').config()
}

module.exports = {
  entry: resolve(__dirname, 'client/index.js'),
  output: {
    path: resolve('./public'),
    filename: 'bundle.js'
  },
  devServer: {
    contentBase: './public'
  },
  plugins: [
    new webpack.DefinePlugin({
      GRAPHQL_ENDPOINT: JSON.stringify(process.env.GRAPHQL_ENDPOINT || 'http://localhost:4000/graph'),
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
