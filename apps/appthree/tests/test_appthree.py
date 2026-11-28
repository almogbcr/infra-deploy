from apps.appthree.app import message


def test_message():
    assert message() == "Hello from appthree"
