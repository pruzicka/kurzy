# Streaming (HLS) Future Plan

This is a future/manual pipeline to encode HLS on a laptop and upload to R2.
It is separate from Active Storage.

## Why

- Better streaming UX (fast start, adaptive bitrate).
- Can serve large videos without full download.
- Requires a separate media pipeline.

## R2 Object Layout (prefixes)

Use a prefix per course+segment so each video can have its own `master.m3u8`.

Example:

- `courses/<course-slug>/<segment-slug>/master.m3u8`
- `courses/<course-slug>/<segment-slug>/720p/segment_0001.ts`
- `courses/<course-slug>/<segment-slug>/720p/segment_0002.ts`
- `courses/<course-slug>/<segment-slug>/360p/segment_0001.ts`

Note: R2 "folders" are just prefixes. You do not need to create them in advance.

## Encoding (example, single 720p)

```
ffmpeg -i input.mov \
  -vf "scale=-2:720" \
  -c:v libx264 -profile:v main -crf 20 -g 48 -keyint_min 48 -sc_threshold 0 \
  -c:a aac -b:a 128k \
  -hls_time 6 -hls_playlist_type vod \
  -hls_segment_filename "720p/segment_%04d.ts" \
  720p/index.m3u8
```

## Encoding (multi-bitrate + master playlist)

This is more complex; we would generate multiple renditions and a master playlist
that references them. Example layout:

- `360p/index.m3u8`
- `720p/index.m3u8`
- `master.m3u8` (points at 360p + 720p)

We can add a scripted pipeline later to automate this.

## Upload to R2

Upload the whole directory to the desired prefix:

```
rclone copy ./output/ r2:kurzy-app-production/courses/<course>/<segment>/
```

Or use `aws s3 sync` with the R2 endpoint.

## Player

- Video.js or hls.js can play HLS.
- Safari supports HLS natively.
- For access control, serve the master playlist from an auth-gated endpoint
  and issue short-lived signed URLs for segments.

