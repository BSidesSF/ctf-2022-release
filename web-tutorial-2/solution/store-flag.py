from google.cloud import pubsub_v1

# Publishes a message to a Cloud Pub/Sub topic.
def store_flag(request):
    # Instantiates a Pub/Sub client
    if request.method == 'OPTIONS':
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
            }
        return ('', 204, headers)
    headers = {'Access-Control-Allow-Origin': '*'}
    publisher = pubsub_v1.PublisherClient()
    PROJECT_ID = 'arboretum-backend'
    topic_name = 'flagstore'
    request_args = request.args
    if request_args and 'flag' in request_args:
        flag = request_args['flag']
        flag_bytes = flag.encode('utf-8')
        topic_path = publisher.topic_path(PROJECT_ID, topic_name)
        publish_future = publisher.publish(topic_path, data=flag_bytes)
        publish_future.result()  # Verify the publish succeeded
        return ('Flag stored.',200,headers)
    return ('No flag parameter in request',200,headers)