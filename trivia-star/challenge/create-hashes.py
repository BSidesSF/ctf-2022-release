import hashlib
output = ["5f2b5e62b65230eb7fe1856556bad37ed661f299a791df5acad939d4b35a7835"]
fx = open('salt.csv','r')
fy = open('hashes.csv','r')
lines = fx.read().split(",")
hashes = fy.read().split(",")
for i, line in enumerate(lines):
	line = line + output[i]
	output.append(hashlib.sha256(bytes(line,'utf-8')).hexdigest())
	print(output[i]+',')
	#print(output[i]==hashes[i])