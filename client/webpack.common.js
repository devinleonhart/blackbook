const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin')

module.exports = {
  entry: ['./src/main.js'],
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    rules: [{
      test: /\.(s*)css$/,
      use: [
        'vue-style-loader',
        'css-loader',
        {
          loader: 'postcss-loader',
          options: {
            config: {
              path: path.resolve('./')
            }
          }
        },
        'sass-loader'
        ]
    }, {
      test: /\.vue/,
      use: 'vue-loader'
    }]
  },
  resolve: {
    alias: {
      vue: 'vue/dist/vue.js',
      '@': path.resolve(__dirname, './src'),
    },
    extensions: ['.js', '.vue']
  },
  plugins: [
    new VueLoaderPlugin()
  ]
};
