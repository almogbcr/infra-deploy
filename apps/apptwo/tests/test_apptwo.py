from apps.apptwo.app import message


def test_message():
    assert message() == "Hello from apptwo"
