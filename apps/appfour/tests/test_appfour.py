from apps.appfour.app import message


def test_message():
    assert message() == "Hello from appfour"
