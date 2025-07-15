import { useState, useEffect } from "react";
import type { Cat } from "../services/catApi";
import { getAllCats } from "../services/catApi";
import Spinner from "./Spinner.tsx";
import CatCard from "./CatCard.tsx";

const Cats: React.FC = () => {
  const [cats, setCats] = useState<Cat[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchCats = async () => {
      try {
        const fetchedCats = await getAllCats();
        setCats(fetchedCats);
        setError(null);
      } catch (error) {
        console.log("Error fetching cats:", error);
        setError("Failed to load cats. Please try again.");
      } finally {
        setLoading(false);
      }
    };

    fetchCats();
  }, []);

  return (
    <div className="c-cat-shelter">
      <h1 className="u-text-center">{loading ? "Loading Cats" : "Our Cats"}</h1>

      {loading && <Spinner loading={loading} />}

      {error && (
        <div className="c-error-state u-py-5 u-text-center">
          <div>{error}</div>
        </div>
      )}

      {!loading && !error && (
        <>
          {cats.length > 0 ? (
            <div className="c-cat-shelter__grid">
              {cats.map((cat) => {
                return <CatCard key={cat.id} cat={cat} />;
              })}
            </div>
          ) : (
            <div className="c-empty-state u-py-5 u-text-center">
              <p>No cats found.</p>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default Cats;
