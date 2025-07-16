import { createBrowserRouter, RouterProvider } from "react-router-dom";
import HomePage from "./pages/HomePage";
import AboutPage from "./pages/AboutPage";
import MainLayout from "./layouts/MainLayout";
import NotFound from "./pages/NotFound";
import CatPage, { catLoader } from "./pages/CatPage";

import "./styles/style.scss";

const router = createBrowserRouter([
  {
    path: "/",
    element: <MainLayout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: "about", element: <AboutPage /> },
      {
        path: "cats/:id",
        element: <CatPage />,
        loader: catLoader,
        errorElement: <NotFound />,
      },
      { path: "*", element: <NotFound /> },
    ],
  },
]);

const App = () => {
  return <RouterProvider router={router} />;
};

export default App;
