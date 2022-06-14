pwncap2: pwncap2.c
	gcc -m32 -fPIE -fstack-protector-all -Wl,-z,relro,-z,now -o $@ $^ -static-pie

clean:
	rm pwncap2

docker:
	docker build . -t gcr.io/bsides-sf-ctf-2022/pwncap2:latest
