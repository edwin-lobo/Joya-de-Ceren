/** @type {import('next').NextConfig} */
const nextConfig = {
  // IMPORTANT: Configure static export for S3 deployment
  output: 'export',

  // Optional: Disable image optimization if not using a Next.js host or Lambda@Edge
  // S3/CloudFront alone don't support Next.js Image Optimization by default.
  // Consider a cloud service or third-party loader if needed, or use standard <img> tags.
  images: {
    unoptimized: true,
  },

  // Optional: Needed for static export if using dynamic routes with generateStaticParams
  // trailingSlash: true, // Adjust based on your CloudFront/S3 setup if needed
};

export default nextConfig;
