const copyWebpackPlugin = require("copy-webpack-plugin");
const { resolve } = require("path");
const webpack = require("webpack");

const { GITHUB_TOKEN, GRAPHQL_ENDPOINT, DEBUG, NODE_ENV } = process.env;

if (!GRAPHQL_ENDPOINT) throw Error("Missing GraphQL endpoint!");

const publicFolder = resolve("./public");

module.exports = {
  entry: "./src/index.js",
  output: {
    path: publicFolder,
    filename: "bundle.js"
  },
  devServer: {
    contentBase: publicFolder
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: "elm-hot-loader" },
          {
            loader: "elm-webpack-loader",
            options: {
              cwd: __dirname,
              debug: DEBUG === "true",
              warn: NODE_ENV === "development"
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      GRAPHQL_ENDPOINT: `"${GRAPHQL_ENDPOINT}"`,
      GITHUB_TOKEN: `"${GITHUB_TOKEN}"`
    }),
    new webpack.NamedModulesPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
    new copyWebpackPlugin(["static"])
  ]
};
