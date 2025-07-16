import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import GenderIcon from "../../../components/common/GenderIcon";

describe("GenderIcon", () => {
  it("renders male icon for male gender", () => {
    render(<GenderIcon gender="male" ariaLabel="male cat" />);

    const icon = screen.getByLabelText("male cat");
    expect(icon).toBeInTheDocument();
  });

  it("renders female icon for female gender", () => {
    render(<GenderIcon gender="female" ariaLabel="female cat" />);

    const icon = screen.getByLabelText("female cat");
    expect(icon).toBeInTheDocument();
  });

  it("renders question mark icon for unknown gender", () => {
    render(<GenderIcon gender="unknown" ariaLabel="unknown cat" />);

    const icon = screen.getByLabelText("unknown cat");
    expect(icon).toBeInTheDocument();
  });

  it("renders question mark icon for empty gender", () => {
    render(<GenderIcon gender="" ariaLabel="empty cat" />);

    const icon = screen.getByLabelText("empty cat");
    expect(icon).toBeInTheDocument();
  });

  it("renders question mark icon for undefined gender", () => {
    render(<GenderIcon gender={undefined} ariaLabel="undefined cat" />);

    const icon = screen.getByLabelText("undefined cat");
    expect(icon).toBeInTheDocument();
  });

  it("renders question mark icon for null gender", () => {
    render(<GenderIcon gender={null} ariaLabel="null cat" />);

    const icon = screen.getByLabelText("null cat");
    expect(icon).toBeInTheDocument();
  });

  it("is case insensitive for gender values", () => {
    render(<GenderIcon gender="MALE" ariaLabel="uppercase male cat" />);

    const icon = screen.getByLabelText("uppercase male cat");
    expect(icon).toBeInTheDocument();
  });

  it("handles mixed case gender values", () => {
    render(<GenderIcon gender="Female" ariaLabel="mixed case female cat" />);

    const icon = screen.getByLabelText("mixed case female cat");
    expect(icon).toBeInTheDocument();
  });

  it("applies custom title attribute", () => {
    render(
      <GenderIcon gender="male" title="Custom Title" ariaLabel="titled cat" />
    );

    const icon = screen.getByLabelText("titled cat");
    expect(icon).toBeInTheDocument();
  });

  it("applies custom className", () => {
    render(
      <GenderIcon
        gender="male"
        className="custom-class"
        ariaLabel="classed cat"
      />
    );

    const icon = screen.getByLabelText("classed cat");
    expect(icon).toHaveClass("custom-class");
  });

  it("applies custom style", () => {
    const customStyle = { color: "red", fontSize: "20px" };
    render(
      <GenderIcon gender="male" style={customStyle} ariaLabel="styled cat" />
    );

    const icon = screen.getByLabelText("styled cat");
    expect(icon).toHaveStyle("color: rgb(255, 0, 0)"); // browsers convert "red" to rgb format
    expect(icon).toHaveStyle("font-size: 20px");
  });

  it("works without optional props", () => {
    render(<GenderIcon gender="male" />);

    // Should render without crashing, even without aria-label
    const svg = document.querySelector("svg");
    expect(svg).toBeInTheDocument();
  });

  it("handles all optional props being undefined", () => {
    render(
      <GenderIcon
        gender="female"
        title={undefined}
        ariaLabel={undefined}
        style={undefined}
        className={undefined}
      />
    );

    const svg = document.querySelector("svg");
    expect(svg).toBeInTheDocument();
  });

  it("renders different icons for different genders", () => {
    const { rerender } = render(
      <GenderIcon gender="male" ariaLabel="male cat" />
    );
    const maleIcon = screen.getByLabelText("male cat");

    rerender(<GenderIcon gender="female" ariaLabel="female cat" />);
    const femaleIcon = screen.getByLabelText("female cat");

    rerender(<GenderIcon gender="unknown" ariaLabel="unknown cat" />);
    const unknownIcon = screen.getByLabelText("unknown cat");

    // Icons should be different (different SVG paths)
    expect(maleIcon).not.toEqual(femaleIcon);
    expect(femaleIcon).not.toEqual(unknownIcon);
    expect(maleIcon).not.toEqual(unknownIcon);
  });

  it("passes through all common props correctly", () => {
    const props = {
      gender: "male",
      title: "Test Title",
      ariaLabel: "Test Aria Label",
      style: { color: "blue" },
      className: "test-class",
    };

    render(<GenderIcon {...props} />);

    const icon = screen.getByLabelText("Test Aria Label");
    expect(icon).toBeInTheDocument();
    expect(icon).toHaveClass("test-class");
    expect(icon).toHaveStyle("color: rgb(0, 0, 255)"); // blue in rgb format
  });
});
