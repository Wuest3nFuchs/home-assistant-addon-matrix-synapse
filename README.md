# Matrix Synapse Add-on (SQLite)

Minimal Home Assistant Add-on packaging Matrix Synapse using SQLite. Intended to be exposed via DuckDNS + Nginx Proxy Manager for TLS.

Quick start:
1. Copy these files to a repository root.
2. In Home Assistant: Supervisor → Add-on Store → Repositories → Add your repo URL.
3. Install the add-on, set option `server_name` to your domain (e.g. `matrix.example.com`) and `enable_registration`/`registration_shared_secret` if you want shared-secret registration.
4. Persist data: map Add‑on folders in the UI (config -> host path, data -> host path).
5. Use Nginx Proxy Manager to route HTTPS traffic to the add-on host port 8008 (HTTP) and 8448 (federation), and manage TLS.

Notes & limitations:
- Uses SQLite (not suitable for large deployments).
- No automatic TLS/Let's Encrypt inside the add-on — use Nginx Proxy Manager / DuckDNS.
- You may need to adjust SYNAPSE_VERSION in the Dockerfile.
