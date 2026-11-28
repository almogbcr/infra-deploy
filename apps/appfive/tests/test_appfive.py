from apps.appfive.app import message


def test_message():
    assert message() == "Hello from appfive"
