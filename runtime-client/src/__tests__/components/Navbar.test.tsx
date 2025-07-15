import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { BrowserRouter } from "react-router-dom";
import Navbar from "../../components/Navbar";

// Helper to render component with router context
const renderWithRouter = (component: React.ReactElement) => {
  return render(<BrowserRouter>{component}</BrowserRouter>);
};

describe("Navbar", () => {
  it("renders the shelter logo", () => {
    renderWithRouter(<Navbar />);

    const logo = screen.getByAltText("Cat Shelter Logo");
    expect(logo).toBeInTheDocument();
    expect(logo).toHaveAttribute("src", "/images/logo.png");
  });

  it("renders the shelter title", () => {
    renderWithRouter(<Navbar />);

    expect(screen.getByText("Alisa's Cat Shelter")).toBeInTheDocument();
  });

  it("renders navigation links", () => {
    renderWithRouter(<Navbar />);

    expect(screen.getByRole("link", { name: "Home" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "About Us" })).toBeInTheDocument();
  });

  it("has correct navigation structure", () => {
    renderWithRouter(<Navbar />);

    const nav = screen.getByRole("navigation");
    expect(nav).toHaveClass("c-nav");
  });

  it("brand link points to home", () => {
    renderWithRouter(<Navbar />);

    const brandLink = screen.getByRole("link", { name: /Cat Shelter Logo/ });
    expect(brandLink).toHaveAttribute("href", "/");
  });
});
