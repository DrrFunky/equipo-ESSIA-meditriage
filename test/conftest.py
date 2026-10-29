import pytest
from main import STORE 

@pytest.fixture(autouse=True)
def clean_store():
    """Limpia el STORE en memoria antes y después de cada test."""
    STORE.clear()
    yield
    STORE.clear()