module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/views/**/*.html.slim',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        blue: 'var(--primary-color)',
        'purple': 'var(--ad-important-color)',
        'pink': 'var(--ad-star-color)',
        'orange': 'var(--ad-caution-color)',
        'green': 'var(--ad-tip-color)',
        'gray-dark': 'var(--text-primary-color)',
        'gray': 'var(--text-light-color)',
        'gray-light': 'var(--primary-light-color)'
      },
      fontFamily: {
        sans: 'var(--main-font)'
      },
    }
  }
}
