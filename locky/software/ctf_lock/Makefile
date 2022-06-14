ctf_lock.hex: ctf_lock.ino
	arduino-cli compile --fqbn arduino:samd:mkr1000 --output-dir build .

upload: ctf_lock.hex
ifndef PORT
	$(error Must specify PORT=port!)
endif
	arduino-cli upload -p $(PORT) --fqbn arduino:samd:mkr1000

reqs:
	arduino-cli core install arduino:samd
	arduino-cli lib install PubSubClient
	arduino-cli lib install WiFi101
