const API_BASE_URL = "/api/shelter_app";

export interface Cat {
  id: number;
  name: string;
  age: number;
  breed: string;
  description: string;
  color: string;
  gender: string;
  adoption_status: "available" | "reserved" | "adopted";
  photos: string; // JSON string array
  app_id: string;
  inserted_at: string;
  updated_at: string;
}

export async function getAllCats(): Promise<Cat[]> {
  const response = await fetch(`${API_BASE_URL}/cats`);

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
