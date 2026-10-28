import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    // product photos go through a Server Action to the NestJS upload endpoint
    serverActions: { bodySizeLimit: "6mb" },
  },
};

export default nextConfig;
