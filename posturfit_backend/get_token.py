import requests

# 1. Masukkan Web API Key dari Langkah 3
API_KEY = "AIzaSyAsFLkkqcO-teYBQ-LqZgOcIrFFO5uIwKE"

# 2. Masukkan akun yang Anda buat di Langkah 2
email = "test@gmail.com"
password = "qwerty"

# URL rahasia Google Identity Toolkit
url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
payload = {
    "email": email,
    "password": password,
    "returnSecureToken": True
}

print("Menghubungi markas Firebase...")
response = requests.post(url, json=payload)

if response.status_code == 200:
    token = response.json().get("idToken")
    print("\n=== TOKEN ANDA BERHASIL DIDAPATKAN ===")
    print(token)
    print("======================================\n")
    print("Copy token di atas dan masukkan ke dalam Gembok (Authorize) di Swagger UI.")
else:
    print("Gagal:", response.json())