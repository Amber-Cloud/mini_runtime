import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import AboutPage from "../../pages/AboutPage";

describe("AboutPage", () => {
  it("renders the main heading", () => {
    render(<AboutPage />);

    const heading = screen.getByRole("heading", { level: 1 });
    expect(heading).toHaveTextContent("About Alisa's Cat Shelter");
  });

  it("renders all section headings", () => {
    render(<AboutPage />);

    expect(
      screen.getByRole("heading", { name: "Our Mission" })
    ).toBeInTheDocument();
    expect(
      screen.getByRole("heading", { name: "What We Do" })
    ).toBeInTheDocument();
    expect(
      screen.getByRole("heading", { name: "Adoption Process" })
    ).toBeInTheDocument();
    expect(
      screen.getByRole("heading", { name: "Get Involved" })
    ).toBeInTheDocument();
  });

  it("renders mission statement content", () => {
    render(<AboutPage />);

    expect(
      screen.getByText(/providing loving care and finding forever homes/)
    ).toBeInTheDocument();
  });

  it("has the correct CSS class on the main container", () => {
    render(<AboutPage />);

    const container = screen.getByRole("heading", { level: 1 }).closest("div");
    expect(container).toHaveClass("c-cat-shelter");
  });
});
