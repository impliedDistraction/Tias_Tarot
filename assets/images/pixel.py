# Event class
class Event:
    def __init__(self, type):
        self.type = type

# Event source
class EventDispatcher:
    def __init__(self):
        self.listeners = {}  # Dictionary of (event_type, [listener_objects])

    def add_listener(self, event_type, listener):
        if event_type not in self.listeners:
            self.listeners[event_type] = []
        self.listeners[event_type].append(listener)

    def remove_listener(self, event_type, listener):
        if event_type in self.listeners:
            self.listeners[event_type].remove(listener)

    def dispatch_event(self, event):
        if event.type in self.listeners:
            for listener in self.listeners[event.type]:
                listener(event)

# Example listener object
class SimpleListener:
    def __init__(self, message):
        self.message = message

    def handle_event(self, event):
        if event.type == "some_event":
            print(f"{self.message} received the event: {event.type}")

# Example event source and listener
event_dispatcher = EventDispatcher()
listener1 = SimpleListener("Listener 1")
listener2 = SimpleListener("Listener 2")

# Adding listeners
event_dispatcher.add_listener("some_event", listener1.handle_event)
event_dispatcher.add_listener("some_event", listener2.handle_event)

# Dispatching an event
event = Event("some_event")
event_dispatcher.dispatch_event(event)