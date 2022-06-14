You can use the payload I've uploaded to my GCS bucket - ``https://storage.googleapis.com/niru-web-tutorials/payload.js``.

This will create an XHR request to fetch the flag and will send it to a cloud function I've set-up at ``https://us-central1-arboretum-backend.cloudfunctions.net/store-flag``. 

The cloud function will push the flag into a pubsub topic that you can read using another cloud function, ``https://us-west1-arboretum-backend.cloudfunctions.net/print-flag``.

Alternatively, you can run ``solution.py``, which automates all of these steps for you. 