import { useLoaderData } from "react-router-dom";
import type { LoaderFunctionArgs } from "react-router-dom";
import { getCatById } from "../services/catApi";
import type { Cat } from "../services/catApi";
import Gallery from "../components/Gallery";

const CatPage = () => {
  const cat = useLoaderData() as Cat;

  return (
    <div className="c-cat-page">
      <h1>{cat.name}</h1>
      <Gallery photos={cat.photos} catName={cat.name} />
      <div className="c-cat-details">
        <p>
          <strong>Age:</strong> {cat.age} {cat.age === 1 ? "year" : "years"} old
        </p>
        <p>
          <strong>Breed:</strong> {cat.breed}
        </p>
        <p>
          <strong>Color:</strong> {cat.color}
        </p>
        <p>
          <strong>Gender:</strong> {cat.gender}
        </p>
        <p>
          <strong>Status:</strong> {cat.adoption_status}
        </p>
        <p>
          <strong>Description:</strong> {cat.description}
        </p>
      </div>
    </div>
  );
};

export const catLoader = async ({ params }: LoaderFunctionArgs) => {
  const id = parseInt(params.id!);

  if (isNaN(id)) {
    throw new Response("Invalid cat ID", { status: 400 });
  }

  try {
    return await getCatById(id);
  } catch (error) {
    // Convert API errors to proper HTTP responses for React Router
    if (error instanceof Error && error.message.includes("not found")) {
      throw new Response("Cat not found", { status: 404 });
    }
    throw new Response("Failed to load cat", { status: 500 });
  }
};

export default CatPage;
