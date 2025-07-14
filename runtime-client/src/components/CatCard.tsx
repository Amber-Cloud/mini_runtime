import { TbGenderMale, TbGenderFemale } from "react-icons/tb";
import { IoColorFilterOutline } from "react-icons/io5";
import { parsePhotos } from "../services/catApi";
import type { Cat } from "../services/catApi";

type Props = {
  cat: Cat;
};

const CatCard: React.FC<Props> = ({ cat }) => {
  const photos = parsePhotos(cat.photos);
  const firstPhoto = photos[0] || "/images/placeholder.jpeg";

  return (
    <div key={cat.id} className="c-cat-card">
      <img src={firstPhoto} alt={cat.name} className="c-cat-card__image" />
      <div className="c-cat-card__content">
        <h3>{cat.name}</h3>
        <p className="c-cat-card__meta">
          {`${cat.age} ${cat.age === 1 ? "year" : "years"} old `}
          {cat.gender?.toLowerCase() === "male" ? (
            <TbGenderMale
              title="Male"
              aria-label="Male cat"
              style={{ verticalAlign: "text-bottom" }}
            />
          ) : (
            <TbGenderFemale
              title="Female"
              aria-label="Female cat"
              style={{ verticalAlign: "text-bottom" }}
            />
          )}
        </p>
        <p className="c-cat-card__meta">
          {`${cat.breed} • `}

          <IoColorFilterOutline style={{ verticalAlign: "text-bottom" }} />

          {` ${cat.color}`}
        </p>
        <p>{cat.description}</p>
      </div>
      <span className={`c-status-badge c-status-badge--${cat.adoption_status}`}>
        {cat.adoption_status}
      </span>
    </div>
  );
};

export default CatCard;
