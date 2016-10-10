var path = require('path');
var webpack = require('webpack');

module.exports = {
  devtool: 'eval',
  // devtool: 'source-map',
  entry: [
    'webpack-dev-server/client?http://localhost:3000',
    'webpack/hot/dev-server',
    './src/main'
  ],
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'bundle.js',
    publicPath: '/static/'
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin()
  ],
  resolve: {
    extensions: ['', '.js', '.coffee'],
    fallback: __dirname + "/node_modules",

    alias: {
      'ramda-extras': path.join(__dirname, '../../../../ramda-extras/src/ramda-extras'),
      'yun': path.join(__dirname, '../../../../yun/src/yun'),
      'super-glue': path.join(__dirname, '../../../src/super-glue')
    }
  },
  module: {
    loaders: [{
      test: /\.coffee?$/,
      loaders: ['react-hot', 'coffee-loader'],
      include: [
        path.join(__dirname, 'src'),
        path.join(__dirname, '../shared'),
        path.join(__dirname, '../../../../yun/src'),
        path.join(__dirname, '../../../src')
      ]
    },
    // {
    //   test: /\.coffee?$/,
    //   loaders: ['coffee-loader'],
    //   include: path.join(__dirname, 'node_modules')
    // },
    // {
    //   test: /\.coffee?$/,
    //   loaders: ['coffee-loader'],
    //   include: path.join(__dirname, '../config.coffee')
    // },
    {
      test: /\.coffee?$/,
      loaders: ['coffee-loader'],
      include: path.join(__dirname, '../../../../ramda-extras/src')
    }//,
    // {
    //   test: /\.coffee?$/,
    //   loaders: ['coffee-loader'],
    //   include: path.join(__dirname, '../../../../yun/src')
    // }//,
    // {
    //   test: /\.coffee?$/,
    //   loaders: ['coffee-loader'],
    //   include: path.join(__dirname, '../../../src3')
    // }//,
    // {
    //   test: /\.coffee?$/,
    //   loaders: ['coffee-loader'],
    //   include: path.join(__dirname, '../shared')
    // }
    ]
  }
};
