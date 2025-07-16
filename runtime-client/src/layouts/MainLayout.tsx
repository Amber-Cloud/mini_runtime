import Navbar from "../components/Navbar";
import { Outlet } from "react-router-dom";
import ScrollToTop from "../components/common/ScrollToTop";

const MainLayout = () => {
  return (
    <>
      <ScrollToTop />
      <Navbar />
      <main className="o-container">
        <Outlet />
      </main>
    </>
  );
};

export default MainLayout;
