const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts')

const config = {
  mode: 'production',
  devtool: 'source-map',
  resolve: {
    extensions: ['.mjs']
  },
  entry: {
    application: [
      path.resolve(__dirname, 'app', 'assets', 'javascript', 'application.js'),
      path.resolve(__dirname, 'app', 'assets', 'stylesheets', 'application.scss')
    ],
    unlink: path.resolve(__dirname, 'app', 'assets', 'javascript', 'unlink.js'),
    govuk_frontend: path.resolve(__dirname, 'app', 'assets', 'javascript', 'govuk-frontend.js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.mjs$/,
        type: 'javascript/auto',
        resolve: {
          fullySpecified: false
        }
      },
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          {
            loader: 'sass-loader',
            options: {
              api: 'legacy'
            }
          }
        ]
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg|ico)$/i,
        type: 'asset/resource'
      }
    ]
  },
  plugins: [
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin()
  ],
  output: {
    path: path.resolve(__dirname, 'app/assets/builds'),
    filename: '[name].js',
    assetModuleFilename: '[name][ext]',
    chunkFilename: '[id].[chunkhash].js'
  }
}

module.exports = config
