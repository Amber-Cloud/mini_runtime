import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect, vi, beforeEach } from "vitest";
import CatFilters from "../../components/CatFilters";
import type { Filters } from "../../services/catApi";

describe("CatFilters", () => {
  const mockOnFilterChange = vi.fn();

  // Helper function to get the gender "All" button
  const getGenderAllButton = () => {
    const allButtons = screen.getAllByText("All");
    const genderAllButton = allButtons.find((btn) =>
      btn.classList.contains("c-cat-filters__button--gender")
    );
    if (!genderAllButton) {
      throw new Error("Gender All button not found");
    }
    return genderAllButton;
  };

  // Helper function to get the status "All" button
  const getStatusAllButton = () => {
    const allStatusButton = document.querySelector(
      ".c-cat-filters__button--status-all"
    );
    if (!allStatusButton) {
      throw new Error("Status All button not found");
    }
    return allStatusButton;
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("renders gender filter buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    expect(screen.getByText("Gender:")).toBeInTheDocument();
    expect(screen.getAllByText("All")).toHaveLength(2);
    expect(screen.getByText("Male")).toBeInTheDocument();
    expect(screen.getByText("Female")).toBeInTheDocument();
  });

  it("renders status filter buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    expect(screen.getByText("Status:")).toBeInTheDocument();
    expect(screen.getAllByText("All")).toHaveLength(2); // One for gender, one for status
    expect(screen.getByText("Available")).toBeInTheDocument();
    expect(screen.getByText("Reserved")).toBeInTheDocument();
    expect(screen.getByText("Adopted")).toBeInTheDocument();
  });

  it("shows gender icons for gender buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const genderButtons = document.querySelectorAll(
      ".c-cat-filters__button--gender"
    );

    genderButtons.forEach((button) => {
      expect(button.querySelector("svg")).toBeInTheDocument();
    });
  });

  it("calls onFilterChange when gender filter is clicked", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const maleButton = screen.getByText("Male");
    fireEvent.click(maleButton);

    expect(mockOnFilterChange).toHaveBeenCalledWith({ gender: "male" });
  });

  it("calls onFilterChange when status filter is clicked", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const availableButton = screen.getByText("Available");
    fireEvent.click(availableButton);

    expect(mockOnFilterChange).toHaveBeenCalledWith({
      adoption_status: "available",
    });
  });

  it("applies active class to selected gender filter", () => {
    const filters: Filters = { gender: "male" };
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const maleButton = screen.getByText("Male");
    expect(maleButton).toHaveClass("c-cat-filters__button--active");
  });

  it("applies active class to selected status filter", () => {
    const filters: Filters = { adoption_status: "available" };
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const availableButton = screen.getByText("Available");
    expect(availableButton).toHaveClass("c-cat-filters__button--active");
  });

  it("applies active class to gender 'All' when no gender filter is selected", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allGenderButton = getGenderAllButton();
    expect(allGenderButton).toHaveClass("c-cat-filters__button--active");
  });

  it("applies active class to status 'All' when no status filter is selected", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allStatusButton = getStatusAllButton();
    expect(allStatusButton).toHaveClass("c-cat-filters__button--active");
  });

  it("resets gender filter when 'All' is clicked", () => {
    const filters: Filters = { gender: "male" };
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allGenderButton = getGenderAllButton();
    fireEvent.click(allGenderButton);

    expect(mockOnFilterChange).toHaveBeenCalledWith({ gender: undefined });
  });

  it("resets status filter when status 'All' is clicked", () => {
    const filters: Filters = { adoption_status: "available" };
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allStatusButton = getStatusAllButton();
    fireEvent.click(allStatusButton);

    expect(mockOnFilterChange).toHaveBeenCalledWith({
      adoption_status: undefined,
    });
  });

  it("preserves other filters when changing one filter", () => {
    const filters: Filters = { gender: "male", adoption_status: "available" };
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const femaleButton = screen.getByText("Female");
    fireEvent.click(femaleButton);

    expect(mockOnFilterChange).toHaveBeenCalledWith({
      gender: "female",
      adoption_status: "available",
    });
  });

  it("has correct CSS classes for gender buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allGenderButton = getGenderAllButton();
    expect(allGenderButton).toHaveClass(
      "c-cat-filters__button",
      "c-cat-filters__button--gender"
    );

    const maleButton = screen.getByText("Male");
    expect(maleButton).toHaveClass(
      "c-cat-filters__button",
      "c-cat-filters__button--gender"
    );
  });

  it("has correct CSS classes for status buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allStatusButton = getStatusAllButton();
    expect(allStatusButton).toHaveClass(
      "c-cat-filters__button",
      "c-cat-filters__button--status-all"
    );

    const availableButton = screen.getByText("Available");
    expect(availableButton).toHaveClass(
      "c-cat-filters__button",
      "c-cat-filters__button--status-available"
    );

    const reservedButton = screen.getByText("Reserved");
    expect(reservedButton).toHaveClass(
      "c-cat-filters__button",
      "c-cat-filters__button--status-reserved"
    );

    const adoptedButton = screen.getByText("Adopted");
    expect(adoptedButton).toHaveClass(
      "c-cat-filters__button",
      "c-cat-filters__button--status-adopted"
    );
  });

  it("has correct container structure", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    expect(document.querySelector(".c-cat-filters")).toBeInTheDocument();
    expect(
      document.querySelector(".c-cat-filters__controls")
    ).toBeInTheDocument();
    expect(document.querySelectorAll(".c-cat-filters__group")).toHaveLength(2);
    expect(document.querySelectorAll(".c-cat-filters__buttons")).toHaveLength(
      2
    );
  });

  it("renders correct number of filter buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allButtons = screen.getAllByRole("button");
    expect(allButtons).toHaveLength(7); // 3 gender + 4 status buttons
  });

  it("handles empty string values correctly", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    const allGenderButton = getGenderAllButton();
    fireEvent.click(allGenderButton);

    expect(mockOnFilterChange).toHaveBeenCalledWith({ gender: undefined });
  });

  it("shows icons only for gender buttons", () => {
    const filters: Filters = {};
    render(
      <CatFilters filters={filters} onFilterChange={mockOnFilterChange} />
    );

    // Gender buttons should have icons
    const maleButton = screen.getByText("Male");
    const femaleButton = screen.getByText("Female");
    const allGenderButton = getGenderAllButton();

    expect(maleButton.querySelector("svg")).toBeInTheDocument();
    expect(femaleButton.querySelector("svg")).toBeInTheDocument();
    expect(allGenderButton.querySelector("svg")).toBeInTheDocument();

    // Status buttons should not have icons
    const availableButton = screen.getByText("Available");
    const reservedButton = screen.getByText("Reserved");
    const adoptedButton = screen.getByText("Adopted");

    expect(availableButton.querySelector("svg")).not.toBeInTheDocument();
    expect(reservedButton.querySelector("svg")).not.toBeInTheDocument();
    expect(adoptedButton.querySelector("svg")).not.toBeInTheDocument();
  });
});
