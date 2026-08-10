# Local data layer

Phase 1 uses Drift 2.34.x as the single logical relational schema across all six targets. Native Flutter targets use SQLite through `drift_flutter`; Web uses Drift's WebAssembly runtime with `sqlite3.wasm` and `drift_worker.js` from the matching Drift release.

## Memory graph

Captures, people, topics, commitments, generic relationships, and embeddings are persisted locally. FTS5 provides keyword search. Embeddings are stored as little-endian Float32 blobs with model and dimension metadata.

## Portable vector search

Phase 1 deliberately uses a portable exact cosine scan over locally stored embeddings instead of a native-only SQLite vector extension. This keeps identical semantics on Web and native targets. The storage/service boundary allows a native ANN or SQLite vector accelerator to be added later without changing memory-domain callers.

This exact scan is correct but O(n × dimensions). The 10,000-vector CI benchmark is characterization only and is not evidence that NFR-4.2.2 is met on a mid-tier device. Native performance must be measured on representative hardware before release; Web receives a separately documented practical ceiling.

## Web persistence

`drift_flutter` automatically selects the best browser storage implementation available (OPFS where possible, otherwise IndexedDB-backed options). The app ships the matching Drift 2.34.3 WebAssembly and worker assets. Browser persistence must still be manually verified on the supported Chrome, Edge, Safari, and Firefox matrix because build CI cannot substitute for each browser's storage capability.
