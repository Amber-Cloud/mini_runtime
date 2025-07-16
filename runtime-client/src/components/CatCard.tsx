import { IoColorFilterOutline } from "react-icons/io5";
import { parsePhotos } from "../services/catApi";
import type { Cat } from "../services/catApi";
import { Link } from "react-router-dom";
import GenderIcon from "./common/GenderIcon";

type Props = {
  cat: Cat;
};

const CatCard: React.FC<Props> = ({ cat }) => {
  const photos = parsePhotos(cat.photos);
  const firstPhoto = photos[0] || "/images/placeholder.jpeg";

  return (
    <Link to={`/cats/${cat.id}`} key={cat.id} className="c-cat-card">
      <img src={firstPhoto} alt={cat.name} className="c-cat-card__image" />
      <div className="c-cat-card__content">
        <h3>{cat.name || "Unknown"}</h3>
        <p className="c-cat-card__meta">
          {`${cat.age} ${cat.age === 1 ? "year" : "years"} old `}
          <GenderIcon
            gender={cat.gender || "unknown gender"}
            title={cat.gender || "unknown gender"}
            ariaLabel={`${cat.gender || "unknown gender"} cat`}
            style={{ verticalAlign: "text-bottom" }}
          />
        </p>
        <p className="c-cat-card__meta">
          {`${cat.breed || "Unknown"} • `}

          <IoColorFilterOutline style={{ verticalAlign: "text-bottom" }} />

          {` ${cat.color || "Unknown"}`}
        </p>
        <p>{cat.description || "We don't know much about this cat yet!"}</p>
      </div>
      <span
        className={`c-status-badge c-status-badge--${
          cat.adoption_status || "unknown"
        }`}
      >
        {cat.adoption_status || "unknown"}
      </span>
    </Link>
  );
};

export default CatCard;
