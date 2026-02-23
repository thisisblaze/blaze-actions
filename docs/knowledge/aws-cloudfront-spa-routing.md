# AWS CloudFront SPA Routing

## Topic

Directly navigating to a deep link (e.g., `https://app.example.com/dashboard/users`) in a deployed React/Vite Single Page Application (SPA) returns a `403 Access Denied` or `404 Not Found` XML payload from Amazon S3 instead of loading the app.

## Context

SPAs use client-side routing (like `react-router`). S3 buckets do not understand client-side routing; if a user requests `/dashboard/users`, S3 literally looks for a file named `users` inside a folder named `dashboard`. If it doesn't exist, S3 returns a 404.

When Origin Access Control (OAC) is enabled, S3 bucket permissions restrict public reads, leading S3 to return a 403 Access Denied instead of a standard 404 when it cannot locate an object.

## Root Cause

CloudFront must intercept S3's 404/403 responses and redirect them back to `/index.html` with a 200 OK status, allowing the SPA's JavaScript router to mount and handle the URL appropriately.

## The Fix

Add custom error responses in your Terraform CloudFront distribution block that capture `403` and `404` errors and rewrite them to `/index.html`.

```hcl
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
```

_Note: You can also accomplish this using CloudFront Functions on Viewer Request, but Error Pages are cheaper and simpler for static assets._
