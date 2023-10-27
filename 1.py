import newrelic.agent
from google.cloud import pubsub_v1
from newrelic.api.transaction import current_transaction

# Initialize the New Relic agent (ensure NEW_RELIC_LICENSE_KEY and NEW_RELIC_APP_NAME are set)
newrelic.agent.initialize(config_file='newrelic.ini')

application = newrelic.agent.register_application(timeout=10.0)

@newrelic.agent.background_task(application, name="GenerateEvent")
def generate_event():
    
    payload = newrelic.agent.create_distributed_trace_payload()    
    attributes = {'traceID': payload.http_safe()}  
    
    with newrelic.agent.FunctionTrace('send_message'):
    # Publish the event with trace and transaction IDs to Pub/Sub
        project_id = "cognitotest-331018"
        topic_id = "test123"
        publisher = pubsub_v1.PublisherClient()        
        topic_path = publisher.topic_path(project_id, topic_id)

        data = "Your event data"
        attributes = attributes
        data_bytes = data.encode("utf-8")

        # Publish the message
        publisher.publish(topic_path, data=data_bytes, **attributes)

        print("Event published with trace ID:", attributes)

if __name__ == "__main__":
    generate_event()


