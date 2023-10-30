import newrelic.agent
from google.cloud import pubsub_v1
from concurrent.futures import TimeoutError

newrelic.agent.initialize(config_file='newrelic2.ini')
application = newrelic.agent.register_application(timeout=10.0)

project_id = "cognitotest-331018"
subscription_id = "test123-sub"
timeout = 5.0

@newrelic.agent.background_task(application, name="SubscriberEvent")
def callback(message: pubsub_v1.subscriber.message.Message) -> None:
    print(f"Received {message}.")
    if message.attributes:
        print("Attributes:")
        for key in message.attributes:
            value = message.attributes.get(key)
            print(f"{key}: {value}")
            if key == 'traceID':
                payload = value
                print("accept_distributed_trace_payload")
                newrelic.agent.accept_distributed_trace_payload(payload, transport_type='Queue')

    message.ack()

def main():
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_id)
    streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
    print(f"Listening for messages on {subscription_path}..\n")

    with subscriber:
        try:
            streaming_pull_future.result(timeout=timeout)
        except TimeoutError:
            streaming_pull_future.cancel()
            streaming_pull_future.result()

if __name__ == "__main__":
    main()
