const API_BASE_URL = "/api/shelter_app";

export interface Cat {
  id: number;
  name: string | null | undefined | "";
  age: number;
  breed: string | null | undefined | "";
  description: string | null | undefined | "";
  color: string | null | undefined | "";
  gender: string | null | undefined | "";
  adoption_status: "available" | "reserved" | "adopted" | null | undefined | "";
  photos: string; // JSON string array
  app_id: string;
  inserted_at: string;
  updated_at: string;
}

export interface Filters {
  gender?: "male" | "female";
  adoption_status?: "available" | "reserved" | "adopted";
}

export async function getCatById(id: number): Promise<Cat> {
  const response = await fetch(`${API_BASE_URL}/cats/${id}`);

  if (!response.ok) {
    if (response.status === 404) {
      throw new Error(`Cat with ID ${id} not found`);
    }
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  const data = await response.json();

  if (data === null) {
    throw new Error(`Cat with ID ${id} not found`);
  }

  return data;
}

export async function getFilteredCats(
  filters: Filters = {}
): Promise<Cat[]> {
  const queryParams = new URLSearchParams();

  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== "" && value !== null) {
      queryParams.append(key, String(value));
    }
  });

  const response = await fetch(
    `${API_BASE_URL}/cats?${queryParams.toString()}`
  );

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return response.json();
}

export function parsePhotos(photosJson: string): string[] {
  try {
    return JSON.parse(photosJson);
  } catch {
    return [];
  }
}
