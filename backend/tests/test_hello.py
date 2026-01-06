import pytest
from backend.app.services.hello import say_hello


def test_say_hello():
    res = say_hello("World")
    assert res["message"] == "Hello, World!"
