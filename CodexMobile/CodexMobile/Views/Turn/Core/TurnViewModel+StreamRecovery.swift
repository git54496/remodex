import Foundation

extension TurnViewModel {
    // Continue a recoverable stream without consuming an unsent composer draft.
    func continueAfterStreamFailure(
        _ failure: CodexStreamFailure, codex: CodexService,
        threadID: String
    ) {
        guard !isSending, codex.recoverableStreamFailure(for: threadID)?.id == failure.id else { return }
        isSending = true
        Task { @MainActor in
            defer { isSending = false }
            do {
                try await codex.continueAfterStreamFailure(threadId: threadID, failureID: failure.id)
            } catch {
                guard codex.recoverableStreamFailuresByThread[threadID]?.id == failure.id else { return }
                codex.dismissStreamFailure(threadId: threadID, failureID: failure.id)
                codex.lastErrorMessage = codex.userFacingTurnErrorMessageForFooter(from: error)
            }
        }
    }
}
