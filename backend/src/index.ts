export default {
	async fetch(request, env, ctx): Promise<Response> {
		const userAgent = request.headers.get('User-Agent') || '';
		if (userAgent.toLowerCase().includes('curl/') || userAgent.toLowerCase().includes('wget/')) {
			const url = new URL(request.url);
			const newRequest = new Request(
				new URL('/lib.sh', url.origin).toString(),
				request
			);
			return env.ASSETS.fetch(newRequest);
		}
		return Response.redirect('https://github.com/uswriting/libdotnew', 302);
	},
} satisfies ExportedHandler<Env>;
