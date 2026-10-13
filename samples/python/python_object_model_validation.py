"""Tracker_HUD Python object/model validation sample.

Expected HUD behaviour:
- Events should show ModelThing as a class/data model for now.
- ModelThing fields should include self.name and self.type.
- __init__ should establish the initial field writes.
- Constructor defaults should be used when an argument is omitted.
- set_name should be recognised as mutating self.name.
- set_type should be recognised as mutating self.type.
- Direct writes such as my_obj.name = ... should update known object state.
- my_obj should be recognised as an instance of ModelThing.
- After my_obj.set_type("phrase"), my_obj.type should be known as "phrase".
- The section should only claim what is visible from this file.
"""


class ModelThing:
    def __init__(self, name="New Object"):
        self.name = name
        self.type = None

    def set_name(self, name):
        self.name = name

    def set_type(self, _type):
        self.type = _type


default_obj = ModelThing()
my_obj = ModelThing("Yo")
my_obj.set_type("phrase")
my_obj.name = "Updated Yo"
