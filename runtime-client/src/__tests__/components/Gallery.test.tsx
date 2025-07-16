import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import Gallery from "../../components/Gallery";

// Mock the catApi parsePhotos function
vi.mock("../../services/catApi", () => ({
  parsePhotos: vi.fn((photosJson: string) => {
    try {
      return JSON.parse(photosJson);
    } catch {
      return [];
    }
  }),
}));

describe("Gallery", () => {
  it("renders single photo without navigation", () => {
    const singlePhoto = '["https://example.com/cat1.jpg"]';

    render(<Gallery photos={singlePhoto} catName="Whiskers" />);

    const image = screen.getByAltText("Whiskers photo 1");
    expect(image).toBeInTheDocument();
    expect(image).toHaveAttribute("src", "https://example.com/cat1.jpg");

    // Should not show navigation arrows for single photo
    expect(screen.queryByLabelText("Previous photo")).not.toBeInTheDocument();
    expect(screen.queryByLabelText("Next photo")).not.toBeInTheDocument();

    // Should not show thumbnails for single photo
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("renders multiple photos with navigation", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg", "https://example.com/cat3.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Luna" />);

    // Should show main image
    const mainImage = screen.getByAltText("Luna photo 1");
    expect(mainImage).toBeInTheDocument();
    expect(mainImage).toHaveAttribute("src", "https://example.com/cat1.jpg");

    // Should show navigation arrows
    expect(screen.getByLabelText("Previous photo")).toBeInTheDocument();
    expect(screen.getByLabelText("Next photo")).toBeInTheDocument();

    // Should show thumbnails
    const buttons = screen.getAllByRole("button");
    expect(buttons).toHaveLength(5); // 3 thumbnails + 2 arrows
  });

  it("navigates to next photo when next button is clicked", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Max" />);

    // Initially shows first photo
    expect(screen.getByAltText("Max photo 1")).toHaveAttribute(
      "src",
      "https://example.com/cat1.jpg"
    );

    // Click next button
    fireEvent.click(screen.getByLabelText("Next photo"));

    // Should show second photo
    expect(screen.getByAltText("Max photo 2")).toHaveAttribute(
      "src",
      "https://example.com/cat2.jpg"
    );
  });

  it("navigates to previous photo when previous button is clicked", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Bella" />);

    // Go to second photo first
    fireEvent.click(screen.getByLabelText("Next photo"));
    expect(screen.getByAltText("Bella photo 2")).toHaveAttribute(
      "src",
      "https://example.com/cat2.jpg"
    );

    // Click previous button
    fireEvent.click(screen.getByLabelText("Previous photo"));

    // Should show first photo
    expect(screen.getByAltText("Bella photo 1")).toHaveAttribute(
      "src",
      "https://example.com/cat1.jpg"
    );
  });

  it("loops from last photo to first when clicking next", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Charlie" />);

    // Go to last photo
    fireEvent.click(screen.getByLabelText("Next photo"));
    expect(screen.getByAltText("Charlie photo 2")).toHaveAttribute(
      "src",
      "https://example.com/cat2.jpg"
    );

    // Click next again - should loop to first
    fireEvent.click(screen.getByLabelText("Next photo"));
    expect(screen.getByAltText("Charlie photo 1")).toHaveAttribute(
      "src",
      "https://example.com/cat1.jpg"
    );
  });

  it("loops from first photo to last when clicking previous", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Milo" />);

    fireEvent.click(screen.getByLabelText("Previous photo"));
    expect(screen.getByAltText("Milo photo 2")).toHaveAttribute(
      "src",
      "https://example.com/cat2.jpg"
    );
  });

  it("navigates to specific photo when thumbnail is clicked", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg", "https://example.com/cat3.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Oscar" />);

    const thumbnails = screen.getAllByAltText(/Oscar thumbnail/);
    fireEvent.click(thumbnails[2]); // Third thumbnail

    expect(screen.getByAltText("Oscar photo 3")).toHaveAttribute(
      "src",
      "https://example.com/cat3.jpg"
    );
  });

  it("shows placeholder image when no photos provided", () => {
    const emptyPhotos = "[]";

    render(<Gallery photos={emptyPhotos} catName="Shadow" />);

    const placeholderImage = screen.getByAltText("Shadow placeholder");
    expect(placeholderImage).toBeInTheDocument();
    expect(placeholderImage).toHaveAttribute("src", "/images/placeholder.jpeg");

    // Should not show navigation or thumbnails
    expect(screen.queryByLabelText("Previous photo")).not.toBeInTheDocument();
    expect(screen.queryByLabelText("Next photo")).not.toBeInTheDocument();
  });

  it("shows placeholder image when photos string is invalid JSON", () => {
    const invalidPhotos = "invalid json";

    render(<Gallery photos={invalidPhotos} catName="Smokey" />);

    const placeholderImage = screen.getByAltText("Smokey placeholder");
    expect(placeholderImage).toBeInTheDocument();
    expect(placeholderImage).toHaveAttribute("src", "/images/placeholder.jpeg");
  });

  it("applies correct CSS classes", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Tiger" />);

    const gallery = screen.getByAltText("Tiger photo 1").closest(".c-gallery");
    expect(gallery).toBeInTheDocument();

    const mainContainer = screen
      .getByAltText("Tiger photo 1")
      .closest(".c-gallery__main");
    expect(mainContainer).toBeInTheDocument();

    const mainImage = screen.getByAltText("Tiger photo 1");
    expect(mainImage).toHaveClass("c-gallery__main-image");

    const prevArrow = screen.getByLabelText("Previous photo");
    expect(prevArrow).toHaveClass("c-gallery__arrow", "c-gallery__arrow--prev");

    const nextArrow = screen.getByLabelText("Next photo");
    expect(nextArrow).toHaveClass("c-gallery__arrow", "c-gallery__arrow--next");
  });

  it("shows active thumbnail styling", () => {
    const multiplePhotos =
      '["https://example.com/cat1.jpg", "https://example.com/cat2.jpg"]';

    render(<Gallery photos={multiplePhotos} catName="Patches" />);

    const thumbnails = screen
      .getAllByRole("button")
      .filter((btn) => btn.querySelector("img")?.alt?.includes("thumbnail"));

    // First thumbnail should be active initially
    expect(thumbnails[0]).toHaveClass("c-gallery__thumbnail--active");
    expect(thumbnails[1]).not.toHaveClass("c-gallery__thumbnail--active");

    // Click second thumbnail
    fireEvent.click(thumbnails[1]);

    // Second thumbnail should now be active
    expect(thumbnails[0]).not.toHaveClass("c-gallery__thumbnail--active");
    expect(thumbnails[1]).toHaveClass("c-gallery__thumbnail--active");
  });
});
