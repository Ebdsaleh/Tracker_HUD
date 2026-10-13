"""Tracker_HUD Python object/model validation sample.

Expected HUD behaviour:
- Events should show ModelThing as a class/data model for now.
- ModelThing fields should include self.name and self.type.
- ModelThing class attributes should be visible as data-model facts.
- __init__ should establish the initial field writes.
- Constructor defaults should be used when an argument is omitted.
- set_name should be recognised as mutating self.name.
- set_type should be recognised as mutating self.type.
- Direct writes such as my_obj.name = ... should update known object state.
- Simple top-level factories returning model instances should be visible.
- @property and @name.setter models should be visible.
- Collection fields such as self.items = [] and self.lookup = {} should be visible.
- Collection mutators such as append and item assignment should update known state.
- @dataclass models should expose annotated fields and constructor state.
- my_obj should be recognised as an instance of ModelThing.
- After my_obj.set_type("phrase"), my_obj.type should be known as "phrase".
- The section should only claim what is visible from this file.
"""

from dataclasses import dataclass


class ModelThing:
    KIND = "tracker-hud-sample"

    def __init__(self, name="New Object"):
        self.name = name
        self.type = None

    def set_name(self, name):
        self.name = name

    def set_type(self, _type):
        self.type = _type


class PropertyThing:
    def __init__(self, display_name="Visible"):
        self._display_name = display_name

    @property
    def display_name(self):
        return self._display_name

    @display_name.setter
    def display_name(self, value):
        self._display_name = value


class CollectionThing:
    def __init__(self):
        self.items = []
        self.lookup = {}

    def add_item(self, item):
        self.items.append(item)

    def add_many(self, values):
        self.items.extend(values)

    def set_lookup(self, key, value):
        self.lookup[key] = value


@dataclass
class DataThing:
    CATEGORY = "dataclass-sample"
    name: str
    kind: str = "generic"


def build_model(name):
    return ModelThing(name=name)


default_obj = ModelThing()
my_obj = ModelThing("Yo")
my_obj.set_name(name="Keyword Yo")
my_obj.set_type(_type="phrase")
my_obj.name = "Updated Yo"

factory_obj = build_model("Factory Yo")

prop_obj = PropertyThing("Property Yo")
prop_obj.display_name = "Renamed Property"

collection_obj = CollectionThing()
collection_obj.add_item("apple")
collection_obj.add_many(["banana", "pear"])
collection_obj.set_lookup("kind", "fruit")
collection_obj.items.append("direct grape")
collection_obj.lookup["color"] = "green"

data_obj = DataThing("Sample")
data_obj.kind = "custom"
