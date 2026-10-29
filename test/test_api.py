from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200

def test_post_patients_201():
    response = client.post(
        "/patients", 
        json={"rut": "12345678-5", "consent_signed": True},
        headers={"Idempotency-Key": "key-123"}
    )
    assert response.status_code == 201

def test_post_patients_sin_consentimiento():
    response = client.post(
        "/patients", 
        json={"rut": "12345678-5", "consent_signed": False}
    )
    assert response.status_code == 422 # O el código de error que maneje tu API

def test_post_patients_rut_invalido():
    response = client.post(
        "/patients", 
        json={"rut": "RUT-INVALIDO", "consent_signed": True}
    )
    assert response.status_code == 422

def test_post_patients_idempotency_replay():
    payload = {"rut": "12345678-5", "consent_signed": True}
    headers = {"Idempotency-Key": "replay-key-1"}
    
    # Primera llamada
    res1 = client.post("/patients", json=payload, headers=headers)
    assert res1.status_code == 201
    
    # Segunda llamada exacta (Replay)
    res2 = client.post("/patients", json=payload, headers=headers)
    assert res2.status_code == 201
    assert res1.json() == res2.json()

def test_post_triage_evaluations():
    # Asumiendo que primero creas un paciente para tener un encounter_id
    response = client.post(
        "/triage-evaluations", 
        json={"encounter_id": "123", "symptoms": ["Dolor de pecho"]}
    )
    assert response.status_code == 202

def test_patch_triage_evaluations():
    response = client.patch(
        "/triage-evaluations/123", 
        json={"status": "confirmed"}
    )
    assert response.status_code in [200, 204] # Ajustar según tu implementación

def test_triage_board_ordering():
    # Validar que ESI 1 aparezca primero
    response = client.get("/triage-board")
    assert response.status_code == 200
    data = response.json()
    if data:
        assert data[0]["esi_category"] == 1 

def test_audit_logs_unauthorized():
    # 401 sin token de seguridad
    response = client.get("/audit-logs")
    assert response.status_code == 401