/**
 * Sample Cloudflare Worker Script
 * 
 * This is a sample Cloudflare Worker script that demonstrates basic functionality.
 * Customize this script to meet your application's specific needs.
 * 
 * Documentation: https://developers.cloudflare.com/workers/
 */

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

/**
 * Main request handler
 * @param {Request} request - The incoming request
 * @returns {Promise<Response>} The response
 */
async function handleRequest(request) {
  const url = new URL(request.url)
  
  // Example: Custom routing logic
  if (url.pathname === '/api/health') {
    return new Response(JSON.stringify({
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'cloudflare-worker'
    }), {
      headers: {
        'content-type': 'application/json;charset=UTF-8',
        'cache-control': 'no-store'
      }
    })
  }
  
  // Example: Add custom headers to all responses
  const response = await fetch(request)
  const newResponse = new Response(response.body, response)
  
  // Add custom headers
  newResponse.headers.set('X-Powered-By', 'Cloudflare Workers')
  newResponse.headers.set('X-Worker-Version', '1.0.0')
  
  // Security headers
  newResponse.headers.set('X-Content-Type-Options', 'nosniff')
  newResponse.headers.set('X-Frame-Options', 'SAMEORIGIN')
  newResponse.headers.set('X-XSS-Protection', '1; mode=block')
  
  return newResponse
}
