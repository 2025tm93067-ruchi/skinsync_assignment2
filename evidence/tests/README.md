# Tests

| File | Produced by | Proves |
|---|---|---|
| [unit-tests-2026-10-23T19-17-44.txt](unit-tests-2026-10-23T19-17-44.txt) | `npm test` | 34 unit tests across the 5 services, at least one per business rule BR1-BR6 (test names start with the rule id). No database is needed: rules are pure functions in each `src/rules.js` |
| [e2e-2026-10-23T19-30-22.txt](e2e-2026-10-23T19-30-22.txt) | `npm run e2e` | Main transaction across all 5 services, 18/18 checks: quiz (BR2) -> recommendations (BR3) -> cart (BR4) -> order CONFIRMED (BR1, BR5, BR6) -> notification delivered via RabbitMQ. **Failure cases:** cart quantity > 5 gives 422, empty cart gives 422, cancelling a CONFIRMED order gives 409, forced payment decline gives 402 with the order FAILED and stock released |
| [e2e-2026-10-23T19-21-07.txt](e2e-2026-10-23T19-21-07.txt) | `npm run e2e` | Same flow **while RabbitMQ was down**: the order still succeeds (broker outage does not block the main transaction) and only the notification check fails, because the event waits in the outbox. It was delivered once the broker came up (see the next run's `outboxPending: 3`) |

The mapping of rules to code and tests is in [docs/business-rules.md](../../docs/business-rules.md).
