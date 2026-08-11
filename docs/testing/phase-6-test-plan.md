# Phase 6 test plan — Tier 1 and Tier 2 proactive insights

Phase 6 adds local proactive insight surfacing on top of the Phase 5 memory/search/graph layer. Tier 1 is reactive and evidence-based from existing local graph/search relationships; Tier 2 is deterministic rule evaluation. No Tier 3 generative inference, provider call, hosted backend, or notification scheduling is introduced in this phase.

## Acceptance rules

- Every insight must contain one or more local source-memory references that can be opened from the UI.
- Tier 1 and Tier 2 generation must run entirely from local data and must not require an API key or network request.
- Dismissed insights must stay dismissed for the same stable insight fingerprint until the underlying evidence materially changes.
- Muting an insight kind suppresses that kind without deleting source memories.
- Duplicate insight candidates must collapse to one stable card.
- Ordering must be deterministic: severity/urgency first, then newest evidence, then stable fingerprint.
- Empty/insufficient evidence must produce no fabricated insight.
- Mobile, Desktop, and Web must have separate screen implementations while sharing the application/domain layer.

## Automated test matrix

| ID | Description | Expected |
| --- | --- | --- |
| P6-01 | Tier 1 related-memory candidate from local graph evidence | Card is generated with source references only when graph evidence exists |
| P6-02 | Tier 1 follow-up candidate from explicit `follows_up_on` relationship | Card references both linked captures and is deterministic |
| P6-03 | Tier 2 overdue commitment rule | Open commitment past due date yields warning with commitment/capture source |
| P6-04 | Tier 2 due-soon commitment rule | Open commitment inside configured horizon yields recommendation; later items do not |
| P6-05 | Tier 2 stale open commitment rule | Open commitment without a due date and older than the configured `createdAt` threshold yields a reminder; the current commitment schema has no `updatedAt`, so Phase 6 does not claim last-activity tracking |
| P6-06 | No fabricated insight on insufficient evidence | Empty/sparse memory produces no candidate |
| P6-07 | Stable fingerprint and duplicate collapse | Equivalent evidence collapses to one insight with deterministic fingerprint |
| P6-08 | Deterministic ordering | Repeated evaluation returns the same ranked order |
| P6-09 | Source traceability | Every surfaced card has resolvable local source references |
| P6-10 | Dismiss persistence | Dismissed fingerprint remains hidden across controller reloads |
| P6-11 | Evidence-change reappearance | Materially changed evidence produces a new fingerprint and can surface again |
| P6-12 | Kind mute/unmute | Muted insight kind is suppressed; unmute restores eligible candidates |
| P6-13 | No destructive side effects | Dismiss/mute never deletes or mutates source memories/commitments |
| P6-14 | Offline/no-provider guarantee | Insight generation path has no provider/key/network dependency |
| P6-15 | Mobile insights route | Mobile route renders mobile-specific insight screen and source navigation affordance |
| P6-16 | Desktop insights route | Desktop route renders desktop-specific persistent insight layout |
| P6-17 | Web insights route | Web route renders web-specific browser-friendly insight layout |
| P6-18 | Screen-family boundary regression | Mobile/Desktop/Web insight screens remain in separate screen directories |
| P6-19 | Existing Phase 0–5 regression suite | Existing tests remain green |
| P6-20 | Six-platform build matrix | Android, iOS simulator, Web, Windows, macOS, and Linux build successfully |

## Manual review script

1. Seed several captures with linked topics/people and at least one explicit follow-up relationship.
2. Seed open commitments that are overdue, due soon, and far in the future.
3. Open Insights on Mobile, Desktop, and Web and compare that the same underlying candidates appear with platform-specific layouts.
4. Open every source reference and confirm it resolves to the underlying local memory/commitment.
5. Dismiss one card, restart/reload the screen, and confirm it stays dismissed.
6. Mute one insight kind, confirm only that kind disappears, then unmute it.
7. Change the underlying evidence for a dismissed insight and confirm the materially changed candidate can surface with a new fingerprint.
8. Repeat with the device offline and with no provider key configured; Tier 1/2 insights must still work.

## Deferred to later phases

- Tier 3 generative AI insight synthesis and contradiction reasoning beyond deterministic/local evidence.
- Local/push notification scheduling for insights.
- Optional encrypted sync of insight preferences across devices.
- Passive ambient capture triggers.

Hosted CI does not claim real-device UX, accessibility, or notification behavior. Those remain manual validation items.