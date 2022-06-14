* The app creates a Firebase Shortlink to point to an image in the GCS bucket ``arboretum-images``. 
* The app makes a request to the Flask backend, which returns a signed URL to the objects in the GCS bucket 
* You can solve the challenge by using Frida to hook into createShortLink() function and modify the function arg to ``https://storage.cloud.google.com/arboretum-images-2022/flag.png``. 
* Run this command to deploy your Frida script, ``frida -U -f com.bsidessf.arboretum -l solution.js --no-pause``