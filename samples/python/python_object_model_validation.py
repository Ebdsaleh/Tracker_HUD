"""Tracker_HUD Python object/model validation sample.

Expected future HUD behaviour:
- Data Models should show ModelThing as a class/data model.
- ModelThing fields should include self.name and self.type.
- __init__ should establish the initial field writes.
- set_name should be recognised as mutating self.name.
- set_type should be recognised as mutating self.type.
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


my_obj = ModelThing("Yo")
my_obj.set_type("phrase")
