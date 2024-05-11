import pygame

class EventBus:
    def __init__(self):
        self.subscribers = {}

    def subscribe(self, event_type, callback):
        if event_type not in self.subscribers:
            self.subscribers[event_type] = []
        self.subscribers[event_type].append(callback)

    def unsubscribe(self, event_type, callback):
        if event_type in self.subscribers:
            self.subscribers[event_type].remove(callback)

    def publish(self, event):
        event_type = event.type
        if event_type in self.subscribers:
            for callback in self.subscribers[event_type]:
                callback(event)

# Initialize Pygame
pygame.init()

# Create an instance of the event bus
event_bus = EventBus()

# Example usage: Subscribe to the pygame.MOUSEBUTTONDOWN event
def handle_mouse_click(event):
    print("Mouse clicked at:", event.pos)

event_bus.subscribe(pygame.MOUSEBUTTONDOWN, handle_mouse_click)

# Main game loop
running = True
while running:
    # Get events from Pygame
    for event in pygame.event.get():
        # Publish the event to subscribers
        event_bus.publish(event)
        
        # Handle QUIT event directly to quit the loop
        if event.type == pygame.QUIT:
            running = False

