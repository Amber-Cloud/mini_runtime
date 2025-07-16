import { render, screen, waitFor } from "@testing-library/react";
import { describe, it, expect, vi, beforeEach } from "vitest";
import { BrowserRouter } from "react-router-dom";
import Cats from "../../components/Cats";
import type { Cat } from "../../services/catApi";

vi.mock("../../services/catApi", () => ({
  getAllCats: vi.fn(),
  parsePhotos: vi.fn((photosJson: string) => {
    try {
      return JSON.parse(photosJson);
    } catch {
      return [];
    }
  }),
}));

vi.mock("../../components/common/Spinner", () => ({
  default: ({ loading }: { loading: boolean }) =>
    loading ? <div data-testid="loading-spinner">Loading...</div> : null,
}));

import { getAllCats } from "../../services/catApi";

// Helper function to render with Router
const renderWithRouter = (component: React.ReactElement) => {
  return render(<BrowserRouter>{component}</BrowserRouter>);
};

const mockCats: Cat[] = [
  {
    id: 1,
    name: "Whiskers",
    age: 2,
    breed: "Persian",
    description: "A lovely cat",
    color: "Orange",
    gender: "male",
    adoption_status: "available",
    photos: '["https://example.com/cat1.jpg"]',
    app_id: "shelter_app",
    inserted_at: "2024-01-01T00:00:00Z",
    updated_at: "2024-01-01T00:00:00Z",
  },
  {
    id: 2,
    name: "Luna",
    age: 3,
    breed: "Siamese",
    description: "A playful cat",
    color: "White",
    gender: "female",
    adoption_status: "reserved",
    photos: '["https://example.com/cat2.jpg"]',
    app_id: "shelter_app",
    inserted_at: "2024-01-01T00:00:00Z",
    updated_at: "2024-01-01T00:00:00Z",
  },
];

describe("Cats", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("shows loading state initially", () => {
    // Mock a pending promise
    vi.mocked(getAllCats).mockImplementation(() => new Promise(() => {}));

    renderWithRouter(<Cats />);

    expect(screen.getByText("Loading Cats")).toBeInTheDocument();
    expect(screen.getByTestId("loading-spinner")).toBeInTheDocument();
  });

  it("displays cats after successful fetch", async () => {
    vi.mocked(getAllCats).mockResolvedValue(mockCats);

    renderWithRouter(<Cats />);

    await waitFor(() => {
      expect(screen.getByText("Our Cats")).toBeInTheDocument();
    });

    expect(screen.getByText("Whiskers")).toBeInTheDocument();
    expect(screen.getByText("Luna")).toBeInTheDocument();
  });

  it("displays error message when fetch fails", async () => {
    vi.mocked(getAllCats).mockRejectedValue(new Error("API Error"));

    renderWithRouter(<Cats />);

    await waitFor(() => {
      expect(
        screen.getByText("Failed to load cats. Please try again.")
      ).toBeInTheDocument();
    });

    expect(screen.queryByText("Whiskers")).not.toBeInTheDocument();
    expect(screen.queryByTestId("loading-spinner")).not.toBeInTheDocument();
  });

  it("displays empty state when no cats are returned", async () => {
    vi.mocked(getAllCats).mockResolvedValue([]);

    renderWithRouter(<Cats />);

    await waitFor(() => {
      expect(screen.getByText("Our Cats")).toBeInTheDocument();
    });

    expect(screen.getByText("No cats found.")).toBeInTheDocument();
  });

  it("renders cats in a grid layout", async () => {
    vi.mocked(getAllCats).mockResolvedValue(mockCats);

    renderWithRouter(<Cats />);

    await waitFor(() => {
      const grid = screen.getByText("Whiskers").closest(".c-cat-page__grid");
      expect(grid).toBeInTheDocument();
    });
  });

  it("has correct main container class", () => {
    vi.mocked(getAllCats).mockImplementation(() => new Promise(() => {}));

    renderWithRouter(<Cats />);

    const container = screen.getByText("Loading Cats").closest(".c-cat-page");
    expect(container).toBeInTheDocument();
  });

  it("calls getAllCats on component mount", () => {
    vi.mocked(getAllCats).mockResolvedValue([]);

    renderWithRouter(<Cats />);

    expect(getAllCats).toHaveBeenCalledTimes(1);
  });

  it("handles loading state transition correctly", async () => {
    vi.mocked(getAllCats).mockResolvedValue(mockCats);

    renderWithRouter(<Cats />);

    // Initially shows loading
    expect(screen.getByText("Loading Cats")).toBeInTheDocument();

    // After loading, shows cats
    await waitFor(() => {
      expect(screen.getByText("Our Cats")).toBeInTheDocument();
      expect(screen.queryByText("Loading Cats")).not.toBeInTheDocument();
    });
  });

  it("error state has correct styling classes", async () => {
    vi.mocked(getAllCats).mockRejectedValue(new Error("API Error"));

    renderWithRouter(<Cats />);

    await waitFor(() => {
      const errorDiv = screen
        .getByText("Failed to load cats. Please try again.")
        .closest(".c-error-state");
      expect(errorDiv).toBeInTheDocument();
      expect(errorDiv).toHaveClass("u-py-5", "u-text-center");
    });
  });

  it("empty state has correct styling classes", async () => {
    vi.mocked(getAllCats).mockResolvedValue([]);

    renderWithRouter(<Cats />);

    await waitFor(() => {
      const emptyDiv = screen
        .getByText("No cats found.")
        .closest(".c-empty-state");
      expect(emptyDiv).toBeInTheDocument();
      expect(emptyDiv).toHaveClass("u-py-5", "u-text-center");
    });
  });

  it("heading has correct text alignment class", () => {
    vi.mocked(getAllCats).mockImplementation(() => new Promise(() => {}));

    renderWithRouter(<Cats />);

    const heading = screen.getByText("Loading Cats");
    expect(heading).toHaveClass("u-text-center");
  });

  it("renders correct number of cat cards", async () => {
    vi.mocked(getAllCats).mockResolvedValue(mockCats);

    renderWithRouter(<Cats />);

    await waitFor(() => {
      expect(screen.getByText("Whiskers")).toBeInTheDocument();
      expect(screen.getByText("Luna")).toBeInTheDocument();
    });
  });
});
