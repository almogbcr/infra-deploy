from apps.appseven.app import message


def test_message():
    assert message() == "Hello from appseven"
