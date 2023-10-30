import newrelic.agent
from google.cloud import pubsub_v1
import random
from newrelic.api.transaction import current_transaction

# Initialize the New Relic agent (ensure NEW_RELIC_LICENSE_KEY and NEW_RELIC_APP_NAME are set)
newrelic.agent.initialize(config_file='newrelic.ini')

application = newrelic.agent.register_application(timeout=10.0)

@newrelic.agent.background_task(application, name="GenerateEvent")
def generate_event():
    
    payload = newrelic.agent.create_distributed_trace_payload()    

    
    with newrelic.agent.FunctionTrace('send_message'):
    # Publish the event with trace and transaction IDs to Pub/Sub
        project_id = "cognitotest-331018"
        topic_id = "test123"
        publisher = pubsub_v1.PublisherClient()        
        topic_path = publisher.topic_path(project_id, topic_id)
        n = random.randint(0, 1000)
        data_str = f"Message number {n}"
        # Data must be a bytestring
        data = data_str.encode("utf-8")

        # Publish the message
        # publisher.publish(topic_path, data=data_bytes, **attributes)
        future = publisher.publish(
            topic_path, data, traceID=payload.http_safe()
        )
        print(future.result())



if __name__ == "__main__":
    generate_event()


