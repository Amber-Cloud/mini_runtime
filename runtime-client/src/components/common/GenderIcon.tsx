import { TbGenderMale, TbGenderFemale, TbQuestionMark } from "react-icons/tb";
import type { CSSProperties } from "react";

type GenderIconProps = {
  gender?: string;
  title?: string;
  ariaLabel?: string;
  style?: CSSProperties;
  className?: string;
};

const GenderIcon: React.FC<GenderIconProps> = ({
  gender,
  title,
  ariaLabel,
  style,
  className,
}) => {
  const normalized = gender?.toLowerCase();
  const commonProps = {
    title,
    "aria-label": ariaLabel,
    style,
    className,
  };

  if (normalized === "male") return <TbGenderMale {...commonProps} />;
  if (normalized === "female") return <TbGenderFemale {...commonProps} />;
  return <TbQuestionMark {...commonProps} />;
};

export default GenderIcon;
