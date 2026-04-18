import Testing
@testable import GeminiUsageTracker

@MainActor
@Test func previewDashboardModelProvidesLoadedSampleData() {
    let viewModel = PreviewSupport.makeDashboardViewModel()

    #expect(viewModel.currentUsage?.modelName == "Gemini 2.5 Pro")
    #expect(viewModel.currentUsage?.requestsUsed == 128)
    #expect(viewModel.currentUsage?.tokensUsed == 1_420_000)
    #expect(viewModel.usageState?.source == .mock)
    #expect(viewModel.historicalData.count == 7)
    #expect(viewModel.isLoading == false)
}
