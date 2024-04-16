const path = require('path')

const fontsourceRewrite = (asset) =>
  path.relative(path.join(__dirname, 'node_modules'), asset.absolutePath)

module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-nesting'),
    require('autoprefixer'),
    require('postcss-url')([
      // Rewrite font import paths to match Rails asset pipeline
      {
        filter: /files\/(jost|jetbrains-mono)/,
        url: fontsourceRewrite
      },
      {
        filter: /remixicon/,
        url: fontsourceRewrite
      }
    ])
  ],
  map: false
}
