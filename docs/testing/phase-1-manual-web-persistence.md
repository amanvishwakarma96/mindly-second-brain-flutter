# Phase 1 manual Web persistence smoke test

1. Run `flutter run -d chrome` and ensure `sqlite3.wasm` is served as `application/wasm`.
2. Create a capture through a temporary debug harness or repository call and note its id.
3. Reload the page. Confirm the capture is still present.
4. Close and reopen the browser tab. Confirm the capture is still present.
5. Repeat in current Chrome, Edge, Firefox, and Safari.
6. Clear site data and confirm the record is gone.
7. Record the storage implementation reported by Drift and any missing browser features.

A browser falling back to non-persistent in-memory storage is a Phase 1 blocker for that browser and must not be silently accepted.
