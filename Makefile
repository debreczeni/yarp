
build:
	docker build -t ianblenke/yarp .

run:
	docker inspect memcached > /dev/null 2>&1 || docker run --name memcached -p 11211:11211 -d memcached
	docker inspect yarp-data > /dev/null 2>&1 || docker run --name yarp-data busybox mkdir -p /cache
	( docker inspect yarp > /dev/null 2>&1 && docker stop yarp || true ) || true
	( docker inspect yarp > /dev/null 2>&1 && docker rm yarp  || true ) || true
	sleep 1
	docker run --name yarp -p 33333:24591 -d \
		-e YARP_CACHE_THRESHOLD=50000 \
		-e YARP_LARGE_CACHE=file \
		-e YARP_SMALL_CACHE=memcache \
		-e YARP_CACHE_TTL=86400 \
		-e YARP_FILECACHE_MAX_BYTES=250000000 \
		-e YARP_FILECACHE_PATH=/cache \
		-e YARP_UPSTREAM=https://rubygems.org \
		-e MEMCACHIER_SERVERS=172.17.42.1:11211 \
		-e PORT=24591 \
		-e UNICORN_KEEPALIVE=20 \
		-e UNICORN_THREADS=10 \
		-e UNICORN_TIMEOUT=30 \
		-e UNICORN_WORKERS=2 \
		--volumes-from yarp-data \
		ianblenke/yarp 
