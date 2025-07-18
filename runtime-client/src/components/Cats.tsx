import { useState, useEffect } from "react";
import type { Cat, Filters } from "../services/catApi";
import { getFilteredCats } from "../services/catApi";
import Spinner from "./common/Spinner.tsx";
import CatCard from "./CatCard.tsx";
import CatFilters from "./CatFilters.tsx";

const Cats: React.FC = () => {
  const [cats, setCats] = useState<Cat[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<Filters>({});

  useEffect(() => {
    const fetchCats = async () => {
      try {
        setLoading(true);
        const fetchedCats = await getFilteredCats(filters);
        setCats(fetchedCats);
        setError(null);
      } catch (error) {
        console.log("Error fetching cats:", error);
        setError("Failed to load cats. Try to refresh in 30 seconds.");
      } finally {
        setLoading(false);
      }
    };

    fetchCats();
  }, [filters]);

  return (
    <div className="c-cat-page">
      <h1 className="u-text-center">{loading ? "Loading Cats" : "Our Cats"}</h1>

      <CatFilters filters={filters} onFilterChange={setFilters} />

      {loading && <Spinner loading={loading} />}

      {error && (
        <div className="c-error-state u-py-5 u-text-center">
          <div>{error}</div>
        </div>
      )}

      {!loading && !error && (
        <>
          {cats.length > 0 ? (
            <div className="c-cat-page__grid">
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
