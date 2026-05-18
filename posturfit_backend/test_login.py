import requests

s = requests.Session()
base = "http://localhost:8000"

tests = [
    ("admin", "posturfit2024", "huruf kecil -- HARUS DITOLAK"),
    ("Admin", "posturfit2024", "huruf besar A -- HARUS DITERIMA"),
    ("ADMIN", "posturfit2024", "semua besar -- HARUS DITOLAK"),
]

for username, password, label in tests:
    r = s.post(base + "/admin/login", data={"username": username, "password": password}, allow_redirects=False)
    if r.status_code in (302, 303):
        result = "DITERIMA (302)"
    elif r.status_code == 400:
        result = "DITOLAK  (400)"
    else:
        result = "status " + str(r.status_code)
    print("  [" + result + "] username=\"" + username + "\" -- " + label)
    s.get(base + "/admin/logout", allow_redirects=False)
