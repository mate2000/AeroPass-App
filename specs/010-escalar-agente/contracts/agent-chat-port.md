# Contract: `AgentChatRepository`

Per research.md §6. The chat is informational: it answers questions and never produces an
escalation outcome (FR-021, SC-011).

## Interface

```text
abstract class AgentChatRepository {
  Future<Result<String>> send(String message);   // returns the agent's reply
}
```

- Text only. There is no method, parameter or type for an attachment (FR-014).
- Nothing it returns is ever interpreted as an outcome; outcomes come only from
  `EscalationRepository.getStatus()`.
- Messages are held in memory by the chat screen and never persisted.

## Dev fake

`DevAgentChatRepository` replies by echoing the message with a fixed prefix, enough to walk the
flow.

## Tests

1. `send` returns the reply for a text message.
2. Transport failure → `Result.error`; the chat screen shows the message as not sent.
3. The chat screen renders no attachment control, and its notice states that the chat cannot
   complete verification and never accepts documents.
4. Sending any message never changes the escalation screen's state.
