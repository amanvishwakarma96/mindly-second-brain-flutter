# Phase 4 test plan — audio capture and transcription

Phase 4 adds explicit microphone capture, native Whisper.cpp transcription, Web cloud transcription with explicit consent, optional raw-audio deletion, and handoff into the existing Phase 3 text extraction pipeline. Native recordings must remain local unless the user explicitly chooses a cloud transcription path on Web.

## Critical automated tests

| ID | Test | Expected result |
|---|---|---|
| P4-01 | Recorder permission denied | Capture does not start; no file/network side effect; clear recoverable state is returned. |
| P4-02 | Native recording start/stop | Recorder uses 16 kHz mono WAV and returns a local file path after stop. |
| P4-03 | Recording indicator state | UI/controller reports recording only while microphone capture is active and clears on stop/cancel/error. |
| P4-04 | Cancel recording | Temporary recording is discarded and no transcription/extraction request runs. |
| P4-05 | Native transcription model missing | App reports model-required state without sending audio to any provider. |
| P4-06 | Native Whisper transcription | Completed WAV is passed to the native transcriber and the returned transcript is preserved exactly for downstream capture. |
| P4-07 | Web cloud consent required | Web transcription cannot dispatch provider traffic before explicit per-flow acknowledgement. |
| P4-08 | Web key missing | Audio remains available for retry; no transcription request is dispatched. |
| P4-09 | Web spend-cap preflight | Estimated cloud transcription cost is checked before provider dispatch; blocked spend prevents the request. |
| P4-10 | Web transcription request contract | Direct BYOK request targets `/v1/audio/transcriptions`, uses multipart audio upload, and does not route through a Mindly backend. |
| P4-11 | Provider/transcriber failure | Raw provider response bodies/API keys are not surfaced or persisted; local recording remains retryable unless the user chose deletion. |
| P4-12 | Transcript to Phase 3 pipeline | Successful transcript is handed into the existing local-first text capture/extraction flow. |
| P4-13 | Delete-after-transcription enabled | Raw audio is deleted only after transcription text is successfully produced and handed off. |
| P4-14 | Delete-after-transcription disabled | Raw audio remains local after successful transcription. |
| P4-15 | Empty transcription | Empty/whitespace transcript is rejected and is not sent to Phase 3 extraction. |
| P4-16 | Platform screen boundaries | Mobile, Desktop, and Web use independent audio-capture screen implementations with no cross-family screen imports. |
| P4-17 | Credential/audio log safety | Automated source checks reject API-key logging and deliberate raw-audio byte logging in Phase 4 code. |
| P4-18 | Regression suite | Existing Phase 0–3 tests remain green. |
| P4-19 | Six-platform builds | Android, iOS simulator, Web, Windows, macOS, and Linux debug builds succeed. |

## Native implementation acceptance

- Android, iOS, Linux, macOS, and Windows use on-device Whisper.cpp through `whisper_ggml_plus`.
- Recording format is 16 kHz, mono WAV so no conversion service is required for the default path.
- Whisper model files live in app-writable local storage. Model download/setup is explicit and never uploads user audio.
- Native transcription must not require an API key or network once the model exists locally.

## Web implementation acceptance

- Web recording remains local in the browser until the user explicitly opts into cloud transcription.
- Cloud transcription uses the user's OpenAI BYOK key directly against the OpenAI Audio Transcriptions API.
- The consent text must make clear that the selected recording will be sent to the provider for transcription.
- Spend-cap preflight from Phase 2 applies before dispatch.

## Manual validation required before release

1. Android and iOS microphone permission prompts, denial/retry, start/stop/cancel, and interruption behavior on real devices.
2. Native Whisper model download and offline re-transcription after disabling network.
3. A five-minute native recording/transcription timing run on a representative 2024+ mid-tier device; hosted CI timing is not accepted as proof of the SRS `<60s` target.
4. macOS microphone entitlement behavior, Windows microphone access, and Linux PulseAudio/FFmpeg dependency behavior on representative installations.
5. Browser microphone capture + explicit cloud consent + real OpenAI BYOK transcription, including provider CORS/browser behavior.
6. Raw-audio deletion preference verified against the device/browser filesystem after successful transcription.

No manual-only case may be reported as automated coverage.