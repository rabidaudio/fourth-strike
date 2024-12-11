/**
 * An implementation of fetch that goes to the server (e.g. XHR).
 * Attaches CSRF tokens to the request.
 */
export function fetch (path, opts) {
  opts = opts || {}
  opts.headers = opts.headers || {}
  const csrfToken = document.getElementsByName('csrf-token')[0].content
  opts.headers['X-CSRF-Token'] ||= csrfToken
  return window.fetch(path, opts)
}
