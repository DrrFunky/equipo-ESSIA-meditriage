from main import normalize_rut, is_valid_rut, mask_rut, classify_esi

# --- Tests de RUT ---
def test_rut_normalization():
    assert normalize_rut(" 12.345.678-5 ") == "12345678-5" # Ajusta el output esperado según tu lógica

def test_rut_validation_valid():
    assert validate_rut("12345678-5") is True

def test_rut_validation_invalid():
    assert validate_rut("12345678-K") is False # RUT falso

def test_rut_masking():
    # Enmascaramiento sin PII
    assert mask_rut("12345678-5") == "1234****-*" 

# --- Tests de ESI ---
def test_classify_esi_category_1():
    # Signos vitales extremos = ESI 1
    assert classify_esi({"sato2": 85, "fc": 140}) == 1

def test_classify_esi_category_5():
    # Sin signos de alarma = ESI 5
    assert classify_esi({"sato2": 98, "fc": 80}) == 5