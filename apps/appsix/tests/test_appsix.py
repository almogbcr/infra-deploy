from apps.appsix.app import message


def test_message():
    assert message() == "Hello from appsix"
