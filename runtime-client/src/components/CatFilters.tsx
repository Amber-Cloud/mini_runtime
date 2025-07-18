import type { Filters } from "../services/catApi";
import { TbGenderMale, TbGenderFemale, TbFilter } from "react-icons/tb";

interface CatFiltersProps {
  filters: Filters;
  onFilterChange: (filters: Filters) => void;
}

const CatFilters: React.FC<CatFiltersProps> = ({ filters, onFilterChange }) => {
  const handleChange = (key: keyof Filters, value: string) => {
    onFilterChange({
      ...filters,
      [key]: value === "" ? undefined : value,
    });
  };

  const genderOptions = [
    { value: "", label: "All", icon: TbFilter },
    { value: "male", label: "Male", icon: TbGenderMale },
    { value: "female", label: "Female", icon: TbGenderFemale },
  ];

  const statusOptions = [
    { value: "", label: "All" },
    { value: "available", label: "Available" },
    { value: "reserved", label: "Reserved" },
    { value: "adopted", label: "Adopted" },
  ];

  return (
    <div className="c-cat-filters">
      <div className="c-cat-filters__controls">
        <div className="c-cat-filters__group">
          <span className="c-cat-filters__label">Gender:</span>
          <div className="c-cat-filters__buttons">
            {genderOptions.map((option) => {
              const Icon = option.icon;
              return (
                <button
                  key={option.value}
                  className={`c-cat-filters__button c-cat-filters__button--gender ${
                    filters.gender === option.value ||
                    (!filters.gender && option.value === "")
                      ? "c-cat-filters__button--active"
                      : ""
                  }`}
                  onClick={() => handleChange("gender", option.value)}
                >
                  <Icon className="c-cat-filters__icon" />
                  {option.label}
                </button>
              );
            })}
          </div>
        </div>

        <div className="c-cat-filters__group">
          <span className="c-cat-filters__label">Status:</span>
          <div className="c-cat-filters__buttons">
            {statusOptions.map((option) => (
              <button
                key={option.value}
                className={`c-cat-filters__button c-cat-filters__button--${
                  option.value || "all"
                } ${
                  filters.adoption_status === option.value ||
                  (!filters.adoption_status && option.value === "")
                    ? "c-cat-filters__button--active"
                    : ""
                }`}
                onClick={() => handleChange("adoption_status", option.value)}
              >
                {option.label}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CatFilters;
