from apps.appeight.app import message


def test_message():
    assert message() == "Hello from appeight"
