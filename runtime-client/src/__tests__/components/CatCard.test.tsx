import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { BrowserRouter } from "react-router-dom";
import CatCard from "../../components/CatCard";
import type { Cat } from "../../services/catApi";

// Helper function to render with Router
const renderWithRouter = (component: React.ReactElement) => {
  return render(<BrowserRouter>{component}</BrowserRouter>);
};

// Mock cat data for testing
const mockCat: Cat = {
  id: 1,
  name: "Whiskers",
  age: 2,
  breed: "Persian",
  description: "A lovely and playful cat looking for a home",
  color: "Orange",
  gender: "male",
  adoption_status: "available",
  photos: '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]',
  app_id: "shelter_app",
  inserted_at: "2024-01-01T00:00:00Z",
  updated_at: "2024-01-01T00:00:00Z",
};

const mockFemaleCat: Cat = {
  ...mockCat,
  id: 2,
  name: "Luna",
  gender: "female",
  adoption_status: "reserved",
};

const mockOldCat: Cat = {
  ...mockCat,
  id: 3,
  name: "Senior",
  age: 1,
  adoption_status: "adopted",
};

const mockCatWithoutPhotos: Cat = {
  ...mockCat,
  id: 4,
  name: "Placeholder",
  photos: "[]",
};

describe("CatCard", () => {
  it("renders cat information correctly", () => {
    renderWithRouter(<CatCard cat={mockCat} />);

    expect(screen.getByText("Whiskers")).toBeInTheDocument();
    expect(screen.getByText("2 years old")).toBeInTheDocument();
    expect(screen.getByText(/Persian/)).toBeInTheDocument();
    expect(screen.getByText(/Orange/)).toBeInTheDocument();
    expect(
      screen.getByText("A lovely and playful cat looking for a home")
    ).toBeInTheDocument();
  });

  it("displays cat image with correct alt text", () => {
    renderWithRouter(<CatCard cat={mockCat} />);

    const image = screen.getByAltText("Whiskers");
    expect(image).toBeInTheDocument();
    expect(image).toHaveAttribute("src", "https://example.com/cat1.jpg");
    expect(image).toHaveClass("c-cat-card__image");
  });

  it("uses placeholder image when no photos available", () => {
    renderWithRouter(<CatCard cat={mockCatWithoutPhotos} />);

    const image = screen.getByAltText("Placeholder");
    expect(image).toHaveAttribute("src", "/images/placeholder.jpeg");
  });

  it("shows male gender icon for male cats", () => {
    renderWithRouter(<CatCard cat={mockCat} />);

    const maleIcon = screen.getByLabelText("male cat");
    expect(maleIcon).toBeInTheDocument();
    expect(maleIcon).toHaveAttribute("aria-label", "male cat");
  });

  it("shows female gender icon for female cats", () => {
    renderWithRouter(<CatCard cat={mockFemaleCat} />);

    const femaleIcon = screen.getByLabelText("female cat");
    expect(femaleIcon).toBeInTheDocument();
    expect(femaleIcon).toHaveAttribute("aria-label", "female cat");
  });

  it("handles singular age correctly", () => {
    renderWithRouter(<CatCard cat={mockOldCat} />);

    expect(screen.getByText("1 year old")).toBeInTheDocument();
  });

  it("displays adoption status badge", () => {
    renderWithRouter(<CatCard cat={mockCat} />);

    const badge = screen.getByText("available");
    expect(badge).toBeInTheDocument();
    expect(badge).toHaveClass("c-status-badge", "c-status-badge--available");
  });

  it("displays different adoption status correctly", () => {
    renderWithRouter(<CatCard cat={mockFemaleCat} />);

    const badge = screen.getByText("reserved");
    expect(badge).toHaveClass("c-status-badge--reserved");
  });

  it("has correct card structure", () => {
    renderWithRouter(<CatCard cat={mockCat} />);

    const card = screen.getByText("Whiskers").closest(".c-cat-card");
    expect(card).toBeInTheDocument();

    const content = screen
      .getByText("Whiskers")
      .closest(".c-cat-card__content");
    expect(content).toBeInTheDocument();
  });

  it("displays breed and color information", () => {
    renderWithRouter(<CatCard cat={mockCat} />);

    // Check that breed and color are displayed together
    expect(screen.getByText(/Persian • Orange/)).toBeInTheDocument();
  });
});
