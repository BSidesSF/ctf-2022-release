from google.api_core import retry
from google.cloud import pubsub_v1

def print_flag(request):
  project_id = "arboretum-backend"
  subscription_id = "flagstore-sub"
  if request.method == 'OPTIONS':
      # Allows GET requests from any origin with the Content-Typ
      # header and caches preflight response for an 3600s
      headers = {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Max-Age': '3600'
          }
      return ('', 204, headers)
  headers = {'Access-Control-Allow-Origin': '*'}
  subscriber = pubsub_v1.SubscriberClient()
  subscription_path = subscriber.subscription_path(project_id, subscription_id)

  NUM_MESSAGES = 3
  # Wrap the subscriber in a 'with' block to automatically call close() to
  # close the underlying gRPC channel when done.
  with subscriber:
      # The subscriber pulls a specific number of messages. The actual
      # number of messages pulled may be smaller than max_messages.
      response = subscriber.pull(
          request={"subscription": subscription_path, "max_messages": NUM_MESSAGES},
          retry=retry.Retry(deadline=300),
      )

      if len(response.received_messages) == 0:
          return ('No new messages',200,headers)

      ack_ids = []
      message = ""
      for received_message in response.received_messages:
          message = message + received_message.message.data.decode('utf-8') + ","
          ack_ids.append(received_message.ack_id)

      # Acknowledges the received messages so they will not be sent again.
      subscriber.acknowledge(
          request={"subscription": subscription_path, "ack_ids": ack_ids}
      )
      return (message,200,headers)