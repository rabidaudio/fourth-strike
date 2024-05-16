const esbuild = require('esbuild')

const vuePlugin = require('esbuild-plugin-vue3')
const aliasPlugin = require('esbuild-plugin-alias')

// "build": "esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets",

const CONFIG = {
  entryPoints: ['app/javascript/*.*'],
  format: 'esm',
  plugins: [
    aliasPlugin({
      vue: require.resolve(`vue/dist/${process.env.NODE_ENV === 'production' ? 'vue.esm-browser.prod.js' : 'vue.esm-browser.js'}`)
    }),
    vuePlugin()
  ],
  bundle: true,
  sourcemap: true,
  publicPath: '/assets',
  outdir: 'app/assets/builds',
  logOverride: {
    'commonjs-variable-in-esm': 'silent'
  }
}

async function main () {
  if (process.argv.includes('--watch')) {
    const ctx = await esbuild.context(CONFIG)
    await ctx.watch()
  } else {
    await esbuild.build(CONFIG)
  }
}

main()
