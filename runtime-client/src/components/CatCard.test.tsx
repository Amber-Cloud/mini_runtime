import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import CatCard from "./CatCard";
import type { Cat } from "../services/catApi";

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
    render(<CatCard cat={mockCat} />);

    expect(screen.getByText("Whiskers")).toBeInTheDocument();
    expect(screen.getByText("2 years old")).toBeInTheDocument();
    expect(screen.getByText(/Persian/)).toBeInTheDocument();
    expect(screen.getByText(/Orange/)).toBeInTheDocument();
    expect(
      screen.getByText("A lovely and playful cat looking for a home")
    ).toBeInTheDocument();
  });

  it("displays cat image with correct alt text", () => {
    render(<CatCard cat={mockCat} />);

    const image = screen.getByAltText("Whiskers");
    expect(image).toBeInTheDocument();
    expect(image).toHaveAttribute("src", "https://example.com/cat1.jpg");
    expect(image).toHaveClass("c-cat-card__image");
  });

  it("uses placeholder image when no photos available", () => {
    render(<CatCard cat={mockCatWithoutPhotos} />);

    const image = screen.getByAltText("Placeholder");
    expect(image).toHaveAttribute("src", "/images/placeholder.jpeg");
  });

  it("shows male gender icon for male cats", () => {
    render(<CatCard cat={mockCat} />);

    const maleIcon = screen.getByLabelText("Male cat");
    expect(maleIcon).toBeInTheDocument();
    expect(maleIcon).toHaveAttribute("aria-label", "Male cat");
  });

  it("shows female gender icon for female cats", () => {
    render(<CatCard cat={mockFemaleCat} />);

    const femaleIcon = screen.getByLabelText("Female cat");
    expect(femaleIcon).toBeInTheDocument();
    expect(femaleIcon).toHaveAttribute("aria-label", "Female cat");
  });

  it("handles singular age correctly", () => {
    render(<CatCard cat={mockOldCat} />);

    expect(screen.getByText("1 year old")).toBeInTheDocument();
  });

  it("displays adoption status badge", () => {
    render(<CatCard cat={mockCat} />);

    const badge = screen.getByText("available");
    expect(badge).toBeInTheDocument();
    expect(badge).toHaveClass("c-status-badge", "c-status-badge--available");
  });

  it("displays different adoption status correctly", () => {
    render(<CatCard cat={mockFemaleCat} />);

    const badge = screen.getByText("reserved");
    expect(badge).toHaveClass("c-status-badge--reserved");
  });

  it("has correct card structure", () => {
    render(<CatCard cat={mockCat} />);

    const card = screen.getByText("Whiskers").closest(".c-cat-card");
    expect(card).toBeInTheDocument();

    const content = screen
      .getByText("Whiskers")
      .closest(".c-cat-card__content");
    expect(content).toBeInTheDocument();
  });

  it("displays breed and color information", () => {
    render(<CatCard cat={mockCat} />);

    // Check that breed and color are displayed together
    expect(screen.getByText(/Persian • Orange/)).toBeInTheDocument();
  });
});
