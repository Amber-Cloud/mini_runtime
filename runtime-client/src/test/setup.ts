import '@testing-library/jest-dom'

// Mock the cat API to prevent network calls during tests
global.fetch = vi.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve([]),
  })
) as any