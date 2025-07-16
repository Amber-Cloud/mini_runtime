import type { Cat } from "../services/catApi";
import { IoColorFilterOutline } from "react-icons/io5";
import { FaBirthdayCake, FaPaw, FaHeart } from "react-icons/fa";
import GenderIcon from "./common/GenderIcon";

type Props = {
  cat: Cat;
};

const CatInfo: React.FC<Props> = ({ cat }) => {
  const infoItems = [
    {
      key: "age",
      label: "Age",
      value: `${cat.age} ${cat.age === 1 ? "year" : "years"} old` || "unknown",
      icon: <FaBirthdayCake />,
    },
    {
      key: "breed",
      label: "Breed",
      value: cat.breed || "unknown",
      icon: <FaPaw />,
    },
    {
      key: "color",
      label: "Color",
      value: cat.color || "unknown",
      icon: <IoColorFilterOutline />,
    },
    {
      key: "gender",
      label: "Gender",
      value: cat.gender || "unknown",
      icon: <GenderIcon gender={cat.gender} />,
    },
    {
      key: "status",
      label: "Status",
      value: cat.adoption_status || "unknown",
      icon: <FaHeart />,
      isStatus: true,
    },
  ];

  return (
    <div className="c-cat-info">
      <div className="c-cat-info__grid">
        {infoItems.map((item) => (
          <div key={item.key} className="c-cat-info__item">
            <div className="c-cat-info__icon">{item.icon}</div>
            <div className="c-cat-info__content">
              <span className="c-cat-info__label">{item.label}</span>
              <span
                className={
                  item.isStatus
                    ? `c-cat-info__status c-cat-info__status--${cat.adoption_status}`
                    : "c-cat-info__value"
                }
              >
                {item.value}
              </span>
            </div>
          </div>
        ))}
      </div>

      <div className="c-cat-info__description">
        <h3>About {cat.name}</h3>
        <p>{cat.description || "We don't know much about this cat yet!"}</p>
      </div>
    </div>
  );
};

export default CatInfo;
