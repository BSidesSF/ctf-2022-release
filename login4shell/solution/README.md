Run as:
docker run -p 8000:8000 -p 1389:1389 $(docker build -q .) python3 /poc/poc.py --userip 172.17.0.1
