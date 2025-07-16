import { useState } from "react";
import { parsePhotos } from "../services/catApi";
import { IoIosArrowBack, IoIosArrowForward } from "react-icons/io";

type Props = {
  photos: string; // JSON string array
  catName: string;
};

const Gallery: React.FC<Props> = ({ photos, catName }) => {
  const photoUrls = parsePhotos(photos);
  const [selectedIndex, setSelectedIndex] = useState(0);

  const goToPrevious = () => {
    setSelectedIndex((prevIndex) =>
      prevIndex === 0 ? photoUrls.length - 1 : prevIndex - 1
    );
  };

  const goToNext = () => {
    setSelectedIndex((prevIndex) =>
      prevIndex === photoUrls.length - 1 ? 0 : prevIndex + 1
    );
  };

  if (photoUrls.length === 0) {
    return (
      <div className="c-gallery">
        <div className="c-gallery__main">
          <img
            src="/images/placeholder.jpeg"
            alt={`${catName} placeholder`}
            className="c-gallery__main-image"
          />
        </div>
      </div>
    );
  }

  return (
    <div className="c-gallery">
      <div className="c-gallery__main">
        {photoUrls.length > 1 && (
          <button
            onClick={goToPrevious}
            className="c-gallery__arrow c-gallery__arrow--prev"
            aria-label="Previous photo"
          >
            <IoIosArrowBack />
          </button>
        )}

        <img
          src={photoUrls[selectedIndex]}
          alt={`${catName} photo ${selectedIndex + 1}`}
          className="c-gallery__main-image"
        />

        {photoUrls.length > 1 && (
          <button
            onClick={goToNext}
            className="c-gallery__arrow c-gallery__arrow--next"
            aria-label="Next photo"
          >
            <IoIosArrowForward />
          </button>
        )}
      </div>

      {photoUrls.length > 1 && (
        <div className="c-gallery__thumbnails">
          {photoUrls.map((url, index) => (
            <button
              key={index}
              onClick={() => setSelectedIndex(index)}
              className={`c-gallery__thumbnail ${
                index === selectedIndex ? "c-gallery__thumbnail--active" : ""
              }`}
            >
              <img
                src={url}
                alt={`${catName} thumbnail ${index + 1}`}
                className="c-gallery__thumbnail-image"
              />
            </button>
          ))}
        </div>
      )}
    </div>
  );
};

export default Gallery;
