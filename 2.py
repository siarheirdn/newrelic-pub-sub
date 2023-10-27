import newrelic.agent
from google.cloud import pubsub_v1

def process_message(message):
    # Extract trace context from the message
    data = message.data
    trace_id = message.attributes.get("trace_id")
    span_id = message.attributes.get("span_id")

    # Initialize the New Relic agent (ensure NEW_RELIC_LICENSE_KEY and NEW_RELIC_APP_NAME are set)
    newrelic.agent.initialize()

    # Create a custom trace segment with the trace context
    with newrelic.agent.AutonamingTransaction(
        application="MySubscriberApp",
        trace_id=trace_id,
        span_id=span_id,
        parent_span_id=newrelic.agent.current_transaction().span_id,
        force_terminate=True,
    ):
        print("Received event with trace ID:", trace_id)
        print("Event data:", data)

    # Acknowledge the message to confirm its receipt
    message.ack()

def main():
    # Subscribe to the Pub/Sub topic and process messages
    project_id = "your-project-id"
    subscription_id = "your-pubsub-subscription"
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_id)

    future = subscriber.subscribe(subscription_path, callback=process_message)
    print("Listening for events...")
    future.result()

if __name__ == "__main__":
    main()
