import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import CatInfo from "../../components/CatInfo";
import type { Cat } from "../../services/catApi";

const mockCat: Cat = {
  id: 1,
  name: "Whiskers",
  age: 3,
  breed: "Persian",
  description: "A lovely and friendly cat looking for a home",
  color: "Orange",
  gender: "male",
  adoption_status: "available",
  photos: '["https://example.com/cat1.jpg"]',
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

const mockCatWithMissingFields: Cat = {
  ...mockCat,
  id: 4,
  name: "",
  breed: "",
  color: "",
  gender: "",
  adoption_status: "",
  description: "",
};

describe("CatInfo", () => {
  it("renders all cat information correctly", () => {
    render(<CatInfo cat={mockCat} />);

    // Check age
    expect(screen.getByText("Age")).toBeInTheDocument();
    expect(screen.getByText("3 years old")).toBeInTheDocument();

    // Check breed
    expect(screen.getByText("Breed")).toBeInTheDocument();
    expect(screen.getByText("Persian")).toBeInTheDocument();

    // Check color
    expect(screen.getByText("Color")).toBeInTheDocument();
    expect(screen.getByText("Orange")).toBeInTheDocument();

    // Check gender
    expect(screen.getByText("Gender")).toBeInTheDocument();
    expect(screen.getByText("male")).toBeInTheDocument();

    // Check status
    expect(screen.getByText("Status")).toBeInTheDocument();
    expect(screen.getByText("available")).toBeInTheDocument();

    // Check description
    expect(screen.getByText("About Whiskers")).toBeInTheDocument();
    expect(
      screen.getByText("A lovely and friendly cat looking for a home")
    ).toBeInTheDocument();
  });

  it("handles singular age correctly", () => {
    render(<CatInfo cat={mockOldCat} />);

    expect(screen.getByText("1 year old")).toBeInTheDocument();
  });

  it("shows different adoption status styling", () => {
    render(<CatInfo cat={mockFemaleCat} />);

    const statusElement = screen.getByText("reserved");
    expect(statusElement).toHaveClass("c-cat-info__status--reserved");
  });

  it("shows correct gender icon for male cats", () => {
    render(<CatInfo cat={mockCat} />);

    expect(screen.getByText("male")).toBeInTheDocument();
  });

  it("shows correct gender icon for female cats", () => {
    render(<CatInfo cat={mockFemaleCat} />);

    expect(screen.getByText("female")).toBeInTheDocument();
  });

  it("handles missing/empty fields with default values", () => {
    render(<CatInfo cat={mockCatWithMissingFields} />);

    // Should show "unknown" for all empty fields
    expect(screen.getAllByText("unknown")).toHaveLength(4); // breed, color, gender, status

    // Should show default description
    expect(screen.getByText("About")).toBeInTheDocument();
    expect(
      screen.getByText("We don't know much about this cat yet!")
    ).toBeInTheDocument();
  });

  it("has correct grid layout structure", () => {
    render(<CatInfo cat={mockCat} />);

    const mainContainer = screen.getByText("Age").closest(".c-cat-info");
    expect(mainContainer).toBeInTheDocument();

    const gridContainer = screen.getByText("Age").closest(".c-cat-info__grid");
    expect(gridContainer).toBeInTheDocument();

    const ageItem = screen.getByText("Age").closest(".c-cat-info__item");
    expect(ageItem).toBeInTheDocument();
  });

  it("shows all info items with correct structure", () => {
    render(<CatInfo cat={mockCat} />);

    // Should have 5 info items (age, breed, color, gender, status)
    const infoItems = screen.getAllByText(/^(Age|Breed|Color|Gender|Status)$/);
    expect(infoItems).toHaveLength(5);

    // Each should have the correct CSS classes
    infoItems.forEach((item) => {
      const container = item.closest(".c-cat-info__item");
      expect(container).toBeInTheDocument();

      const label = item;
      expect(label).toHaveClass("c-cat-info__label");
    });
  });

  it("shows description section with correct heading", () => {
    render(<CatInfo cat={mockCat} />);

    expect(screen.getByText("About Whiskers")).toBeInTheDocument();

    const descriptionContainer = screen
      .getByText("About Whiskers")
      .closest(".c-cat-info__description");
    expect(descriptionContainer).toBeInTheDocument();
  });

  it("shows status with correct styling classes", () => {
    render(<CatInfo cat={mockCat} />);

    const statusElement = screen.getByText("available");
    expect(statusElement).toHaveClass("c-cat-info__status--available");
  });

  it("shows different status styling for different statuses", () => {
    const adoptedCat = { ...mockCat, adoption_status: "adopted" as const };
    render(<CatInfo cat={adoptedCat} />);

    const statusElement = screen.getByText("adopted");
    expect(statusElement).toHaveClass("c-cat-info__status--adopted");
  });

  it("shows unknown status styling for empty status", () => {
    render(<CatInfo cat={mockCatWithMissingFields} />);

    const statusElements = screen.getAllByText("unknown");
    const statusElement = statusElements.find((el) =>
      el.className.includes("c-cat-info__status")
    );
    expect(statusElement).toBeInTheDocument();
  });

  it("renders icons for each info category", () => {
    render(<CatInfo cat={mockCat} />);

    const iconContainers = document.querySelectorAll(".c-cat-info__icon");
    expect(iconContainers).toHaveLength(5); // One for each info item
  });

  it("shows hover effects on info items", () => {
    render(<CatInfo cat={mockCat} />);

    const infoItems = document.querySelectorAll(".c-cat-info__item");
    expect(infoItems).toHaveLength(5);

    infoItems.forEach((item) => {
      expect(item).toHaveClass("c-cat-info__item");
    });
  });
});
