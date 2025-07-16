import { render, screen, waitFor } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import App from "../App";

// Mock ScrollToTop to avoid window.scrollTo issues in tests
// ignore scroll behavior in tests
vi.mock("../components/common/ScrollToTop", () => ({
  default: () => null,
}));

// Mock window.scrollTo for jsdom
Object.defineProperty(window, "scrollTo", {
  value: vi.fn(),
  writable: true,
});

describe("App", () => {
  it("renders without crashing", async () => {
    render(<App />);

    // Should render the navbar
    expect(screen.getByRole("navigation")).toBeInTheDocument();

    // Wait for any async operations to complete
    await waitFor(() => {
      expect(screen.getByRole("navigation")).toBeInTheDocument();
    });
  });

  it("renders the navbar with shelter title", async () => {
    render(<App />);

    await waitFor(() => {
      expect(screen.getByText("Alisa's Cat Shelter")).toBeInTheDocument();
    });
  });

  it("renders navigation links", async () => {
    render(<App />);

    await waitFor(() => {
      expect(screen.getByRole("link", { name: "Home" })).toBeInTheDocument();
      expect(
        screen.getByRole("link", { name: "About Us" })
      ).toBeInTheDocument();
    });
  });
});
